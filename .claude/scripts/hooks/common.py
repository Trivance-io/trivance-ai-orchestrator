#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Utilidades comunes para hooks de Claude Code - Enterprise Optimized + Quick Wins.

- Logging estructurado JSONL con contexto rico (session_id, correlation_id)
- Cache inteligente de análisis con TTL configurable
- Performance tracking con métricas automáticas
- Lectura robusta de stdin como JSON
- ResponseFactory para JSON responses consistentes
- Helpers varios optimizados

Claude Code expone CLAUDE_PROJECT_DIR al ejecutar hooks.
Doc: Hooks receive JSON via stdin; environment and paths are available. 
"""
import os, json, sys, datetime, hashlib, uuid, time, threading
from contextlib import contextmanager
from typing import Optional, Dict, Any, Callable

# Configuration constants
class HookConfig:
    # Cache settings
    CACHE_TTL_SEC = 3600
    CACHE_MAX_ENTRIES = 1000
    CACHE_MAX_MEMORY_MB = 50
    CACHE_CLEANUP_INTERVAL_SEC = 300.0
    
    # Performance thresholds
    PERFORMANCE_THRESHOLD_MS = 100.0
    FAST_HASH_CONTENT_SIZE_LIMIT = 1000
    
    # Logging settings
    LOG_BATCH_FLUSH_THRESHOLD = 10
    LOG_BATCH_FLUSH_INTERVAL_SEC = 5.0
    LOG_TEXT_TRUNCATE_LENGTH = 4000
    LOG_COMMAND_MAX_LENGTH = 100
    
    # Hash settings
    USER_HASH_LENGTH = 8
    CONTENT_HASH_LENGTH = 16

def _project_dir() -> str:
    """Returns the project root directory - CORRECTED."""
    # Claude Code always provides CLAUDE_PROJECT_DIR
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR")
    if project_dir:
        return project_dir
    
    # Corrected fallback: navigate up from correct hooks directory structure
    current = os.getcwd()
    
    # Handle .claude/scripts/hooks structure
    if current.endswith('.claude/scripts/hooks'):
        # Go up 3 levels: hooks -> scripts -> .claude -> project_root
        return os.path.dirname(os.path.dirname(os.path.dirname(current)))
    elif current.endswith('.claude/hooks'):
        # Go up 2 levels: hooks -> .claude -> project_root  
        return os.path.dirname(os.path.dirname(current))
    elif current.endswith('.claude'):
        # Go up 1 level: .claude -> project_root
        return os.path.dirname(current)
    
    # Last resort: assume we're already in project root
    return current

def _logs_dir() -> str:
    """Creates and returns the logs directory path with path traversal protection."""
    today = datetime.datetime.now().strftime("%Y-%m-%d")
    project_root = os.path.realpath(_project_dir())
    
    # Construct and validate path to prevent traversal attacks
    logs_path = os.path.realpath(os.path.join(project_root, ".claude", "logs", today))
    
    # Security: ensure logs path is within project directory
    if not logs_path.startswith(project_root):
        raise ValueError(f"Invalid logs path outside project: {logs_path}")
    
    os.makedirs(logs_path, exist_ok=True)
    return logs_path

# Global session context
_session_context = {
    "session_id": None,
    "correlation_id": None
}

def init_session_context(session_id: Optional[str] = None):
    """Inicializa contexto de sesión global."""
    global _session_context
    # Usar session ID de Claude Code si existe, sino generar uno
    _session_context["session_id"] = (
        session_id or 
        os.environ.get("CLAUDE_SESSION_ID") or 
        str(uuid.uuid4())[:8]
    )
    _session_context["correlation_id"] = str(uuid.uuid4())[:8]
    return _session_context

def log_event(filename: str, payload: dict):
    """Escribe una línea JSON con contexto rico en .claude/logs/YYYY-MM-DD/<filename>."""
    path = os.path.join(_logs_dir(), filename)
    payload = dict(payload or {})
    
    # Auto-inicializar session si no existe
    if not _session_context["session_id"]:
        init_session_context()
    
    # Contexto esencial para auditoría
    payload.setdefault("timestamp", datetime.datetime.now().isoformat())
    payload.setdefault("session_id", _session_context["session_id"])
    payload.setdefault("correlation_id", _session_context["correlation_id"])
    payload.setdefault("pid", os.getpid())
    payload.setdefault("hostname", os.uname().nodename)
    
    try:
        with open(path, "a", encoding="utf-8") as f:
            f.write(json.dumps(payload, ensure_ascii=False) + "\n")
    except OSError as e:
        sys.stderr.write(f"[hooks][log_event] error escribiendo log: {e}\n")

def read_stdin_json():
    """Lee stdin y parsea JSON; si falla, devuelve diagnóstico."""
    raw = sys.stdin.read()
    try:
        return json.loads(raw) if raw else {}
    except json.JSONDecodeError as e:
        return {"_raw": raw, "_json_error": str(e)}

def sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()

def short(text: str, n: int = HookConfig.LOG_TEXT_TRUNCATE_LENGTH) -> str:
    return text if len(text) <= n else (text[:n] + f"... [truncated {len(text)-n} chars]")

# Efficient batch logger to reduce threading overhead
class BatchLogger:
    """Logger optimizado que acumula eventos y hace flush periódico."""
    
    def __init__(self, flush_threshold: int = HookConfig.LOG_BATCH_FLUSH_THRESHOLD, 
                 flush_interval: float = HookConfig.LOG_BATCH_FLUSH_INTERVAL_SEC):
        self.queue = []
        self.flush_threshold = flush_threshold
        self.last_flush = time.time()
        self.flush_interval = flush_interval
        self._lock = threading.Lock()
    
    def log_async(self, filename: str, event_data: dict):
        """Acumula evento para logging asíncrono."""
        with self._lock:
            self.queue.append((filename, event_data))
            # Flush si alcanzamos threshold o tiempo límite
            if (len(self.queue) >= self.flush_threshold or 
                time.time() - self.last_flush >= self.flush_interval):
                self._flush()
    
    def _flush(self):
        """Flush todos los eventos acumulados."""
        if not self.queue:
            return
        
        # Procesar todos los eventos en la cola
        for filename, event_data in self.queue:
            log_event(filename, event_data)
        
        self.queue.clear()
        self.last_flush = time.time()

# Global batch logger instance
_batch_logger = BatchLogger()

# Enterprise-grade optimized cache with memory management
class OptimizedAnalysisCache:
    """Cache optimizado enterprise con memory pooling y cleanup automático."""
    
    def __init__(self, ttl: int = HookConfig.CACHE_TTL_SEC, 
                 max_entries: int = HookConfig.CACHE_MAX_ENTRIES, 
                 max_memory_mb: int = HookConfig.CACHE_MAX_MEMORY_MB):
        self.ttl = ttl
        self.max_entries = max_entries
        self.max_memory_bytes = max_memory_mb * 1024 * 1024
        
        # Usar dict ordenado para LRU behavior eficiente
        from collections import OrderedDict
        self.cache: OrderedDict[str, Dict[str, Any]] = OrderedDict()
        
        # RWLock simulado con threading.RLock para mejor performance
        self._lock = threading.RLock()
        
        # Estadísticas de performance
        self.stats = {
            "hits": 0,
            "misses": 0,
            "evictions": 0,
            "memory_bytes": 0
        }
        
        # Cleanup timer
        self._cleanup_timer = None
        self._start_cleanup_timer()
    
    def _start_cleanup_timer(self):
        """Inicia timer de cleanup automático."""
        if self._cleanup_timer:
            self._cleanup_timer.cancel()
        
        # Cleanup periódico configurado
        self._cleanup_timer = threading.Timer(HookConfig.CACHE_CLEANUP_INTERVAL_SEC, self._cleanup_expired)
        self._cleanup_timer.daemon = True
        self._cleanup_timer.start()
    
    def _cleanup_expired(self):
        """Cleanup de entradas expiradas (ejecuta en background)."""
        try:
            with self._lock:
                current_time = time.time()
                expired_keys = []
                
                for key, entry in self.cache.items():
                    if current_time - entry["cached_at"] >= self.ttl:
                        expired_keys.append(key)
                
                for key in expired_keys:
                    entry = self.cache.pop(key, None)
                    if entry:
                        self.stats["memory_bytes"] -= entry.get("memory_size", 0)
                        self.stats["evictions"] += 1
                
                if expired_keys:
                    log_event("cache_cleanup.jsonl", {
                        "event": "expired_cleanup",
                        "expired_count": len(expired_keys),
                        "remaining_count": len(self.cache),
                        "memory_bytes": self.stats["memory_bytes"]
                    })
        except Exception as e:
            log_event("cache_cleanup.jsonl", {
                "event": "cleanup_error",
                "error": str(e)
            })
        finally:
            # Programar siguiente cleanup
            self._start_cleanup_timer()
    
    def _estimate_memory_size(self, obj: Any) -> int:
        """Estima tamaño en memoria de objeto (optimizado)."""
        # Estimación rápida basada en tipo
        if isinstance(obj, str):
            return len(obj.encode('utf-8'))
        elif isinstance(obj, dict):
            # Estimación conservadora para dict
            return sum(len(str(k)) + len(str(v)) for k, v in obj.items()) * 2
        elif isinstance(obj, list):
            return sum(len(str(item)) for item in obj) * 2
        else:
            return len(str(obj)) * 2
    
    def _enforce_memory_limit(self):
        """Fuerza límites de memoria eliminando entradas LRU."""
        while (len(self.cache) > self.max_entries or 
               self.stats["memory_bytes"] > self.max_memory_bytes):
            
            if not self.cache:
                break
                
            # Eliminar entrada más antigua (LRU)
            oldest_key = next(iter(self.cache))
            entry = self.cache.pop(oldest_key)
            self.stats["memory_bytes"] -= entry.get("memory_size", 0)
            self.stats["evictions"] += 1
    
    def get(self, content_hash: str) -> Optional[Dict[str, Any]]:
        """Obtiene entrada del cache con performance optimizada."""
        with self._lock:
            if content_hash not in self.cache:
                return None
            
            entry = self.cache[content_hash]
            current_time = time.time()
            
            # Verificar expiración
            if current_time - entry["cached_at"] >= self.ttl:
                self.cache.pop(content_hash)
                self.stats["memory_bytes"] -= entry.get("memory_size", 0)
                return None
            
            # Mover al final para LRU (touch)
            self.cache.move_to_end(content_hash)
            
            self.stats["hits"] += 1
            return entry["result"]
    
    def set(self, content_hash: str, result: Dict[str, Any]):
        """Almacena resultado en cache con memory management."""
        with self._lock:
            # Calcular tamaño en memoria
            memory_size = self._estimate_memory_size(result)
            
            # Si ya existe, remover entrada anterior
            if content_hash in self.cache:
                old_entry = self.cache.pop(content_hash)
                self.stats["memory_bytes"] -= old_entry.get("memory_size", 0)
            
            # Crear nueva entrada
            entry = {
                "result": result,
                "cached_at": time.time(),
                "memory_size": memory_size
            }
            
            self.cache[content_hash] = entry
            self.stats["memory_bytes"] += memory_size
            
            # Enforcer límites
            self._enforce_memory_limit()
    
    def get_or_analyze(self, content: str, analyzer: Callable) -> Dict[str, Any]:
        """Método principal optimizado para obtener o analizar contenido."""
        # Usar hash más rápido para contenido pequeño
        if len(content) < HookConfig.FAST_HASH_CONTENT_SIZE_LIMIT:
            content_hash = str(hash(content) & 0x7FFFFFFF)  # Hash rápido para contenido pequeño
        else:
            content_hash = hashlib.sha256(content.encode()).hexdigest()[:HookConfig.CONTENT_HASH_LENGTH]
        
        # Intentar cache primero
        cached = self.get(content_hash)
        if cached is not None:
            # Log cache hit usando batch logger - no threading overhead
            _batch_logger.log_async("performance.jsonl", {
                "event": "cache_hit",
                "content_hash": content_hash,
                "content_size": len(content),
                "hit_rate": self.get_hit_rate()
            })
            return cached
        
        # Cache miss - ejecutar análisis
        start_time = time.perf_counter()
        result = analyzer(content)
        analysis_time_ms = (time.perf_counter() - start_time) * 1000
        
        # Almacenar en cache
        self.set(content_hash, result)
        self.stats["misses"] += 1
        
        # Log cache miss usando batch logger - no threading overhead
        _batch_logger.log_async("performance.jsonl", {
            "event": "cache_miss",
            "content_hash": content_hash,
            "content_size": len(content),
            "analysis_time_ms": analysis_time_ms,
            "hit_rate": self.get_hit_rate()
        })
        
        return result
    
    def get_hit_rate(self) -> float:
        """Calcula hit rate actual del cache."""
        total = self.stats["hits"] + self.stats["misses"]
        return (self.stats["hits"] / total * 100) if total > 0 else 0.0
    
    def get_stats(self) -> Dict[str, Any]:
        """Obtiene estadísticas completas del cache."""
        with self._lock:
            return {
                **self.stats,
                "entries_count": len(self.cache),
                "hit_rate_percent": self.get_hit_rate(),
                "memory_mb": self.stats["memory_bytes"] / 1024 / 1024,
                "memory_utilization_percent": (self.stats["memory_bytes"] / self.max_memory_bytes) * 100
            }
    
    def clear(self):
        """Limpia todo el cache."""
        with self._lock:
            self.cache.clear()
            self.stats["memory_bytes"] = 0
            log_event("cache_operation.jsonl", {
                "event": "cache_cleared",
                "timestamp": time.time()
            })
    
    def __del__(self):
        """Cleanup cuando se destruye el cache."""
        if self._cleanup_timer:
            self._cleanup_timer.cancel()

# Cache global con lazy initialization thread-safe
_global_cache = None
_cache_lock = threading.RLock()

def _get_global_cache():
    """Lazy initialization del cache global - thread-safe."""
    global _global_cache
    with _cache_lock:
        if _global_cache is None:
            _global_cache = OptimizedAnalysisCache(
                ttl=HookConfig.CACHE_TTL_SEC, 
                max_entries=HookConfig.CACHE_MAX_ENTRIES, 
                max_memory_mb=HookConfig.CACHE_MAX_MEMORY_MB
            )
        return _global_cache

# Quick Win: Performance tracking
@contextmanager
def track_performance(operation_name: str, **context):
    """Context manager para tracking automático de performance."""
    start_time = time.perf_counter()
    start_memory = 0
    
    try:
        # Intentar obtener uso de memoria si psutil está disponible
        import psutil
        start_memory = psutil.Process().memory_info().rss / 1024 / 1024
    except ImportError:
        pass
    
    correlation_id = str(uuid.uuid4())[:8]
    
    try:
        yield correlation_id
    finally:
        end_time = time.perf_counter()
        duration_ms = (end_time - start_time) * 1000
        
        end_memory = 0
        try:
            end_memory = psutil.Process().memory_info().rss / 1024 / 1024
        except (ImportError, NameError):
            pass
        
        metrics = {
            "event": "performance_track",
            "operation": operation_name,
            "duration_ms": round(duration_ms, 2),
            "memory_delta_mb": round(end_memory - start_memory, 2) if start_memory else 0,
            "correlation_id": correlation_id,
            **context
        }
        
        log_event("performance.jsonl", metrics)
        
        # Alertar si el hook toma más del threshold configurado
        if duration_ms > HookConfig.PERFORMANCE_THRESHOLD_MS:
            log_event("alerts.jsonl", {
                "level": "warning",
                "message": f"Hook '{operation_name}' took {duration_ms:.2f}ms (>{HookConfig.PERFORMANCE_THRESHOLD_MS}ms threshold)",
                "operation": operation_name,
                "duration_ms": duration_ms
            })

def sanitize_for_log(cmd: str, max_len: int = HookConfig.LOG_COMMAND_MAX_LENGTH) -> str:
    """Sanitiza comandos para logging seguro - previene exposición de datos sensibles."""
    # Primero truncar por longitud
    if len(cmd) > max_len:
        cmd = cmd[:max_len] + f"... [truncated {len(cmd)-max_len} chars]"
    
    # Enmascarar posibles secrets o tokens en comandos
    import re
    # Patrones para detectar y enmascarar información sensible
    patterns = [
        (r'(--?token[=\s]+)([^\s]+)', r'\1***'),
        (r'(--?key[=\s]+)([^\s]+)', r'\1***'),
        (r'(--?password[=\s]+)([^\s]+)', r'\1***'),
        (r'(--?secret[=\s]+)([^\s]+)', r'\1***'),
        (r'(-p\s+)([^\s]+)', r'\1***'),  # -p password
        (r'(Bearer\s+)([^\s]+)', r'\1***'),  # Bearer tokens
    ]
    
    for pattern, replacement in patterns:
        cmd = re.sub(pattern, replacement, cmd, flags=re.IGNORECASE)
    
    return cmd

# Función de conveniencia para usar el cache global
def get_cached_analysis(content: str, analyzer: Callable) -> Dict[str, Any]:
    """Usar el cache global para análisis."""
    return _get_global_cache().get_or_analyze(content, analyzer)

# Función simple para logging de decisiones AI
def log_decision(decision: str, reason: str, confidence: str = "high"):
    """Log simple de decisiones AI - minimalista y efectivo."""
    # Anonimizar usuario con hash para privacidad
    user = os.environ.get("USER", "unknown")
    user_hash = hashlib.sha256(user.encode('utf-8')).hexdigest()[:HookConfig.USER_HASH_LENGTH]
    
    log_event("decisions.jsonl", {
        "decision": decision,
        "reason": reason,
        "confidence": confidence,
        "user_context_hash": user_hash
    })
