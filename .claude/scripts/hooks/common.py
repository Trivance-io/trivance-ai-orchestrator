#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Utilidades comunes para hooks de Claude Code - Optimizado y Simplificado.

Funciones core usadas por los hooks:
- read_stdin_json: Lee y parsea JSON de stdin
- log_event: Logging estructurado JSONL  
- log_decision: Log de decisiones AI
- init_session_context: Inicializa contexto de sesión
- track_performance: Tracking de performance
- get_cached_analysis: Cache inteligente para análisis

Claude Code expone CLAUDE_PROJECT_DIR al ejecutar hooks.
"""
import os, json, sys, datetime, hashlib, uuid, time, threading
from contextlib import contextmanager
from typing import Optional, Dict, Any, Callable
from collections import OrderedDict

try:
    import psutil
except ImportError:
    psutil = None

# Configuration constants
CACHE_TTL_SEC = 3600
CACHE_MAX_ENTRIES = 1000
CACHE_MAX_MEMORY_MB = 50
CACHE_CLEANUP_INTERVAL_SEC = 300.0
PERFORMANCE_THRESHOLD_MS = 100.0
CONTENT_HASH_LENGTH = 16
MAX_STDIN_SIZE = 10485760  # 10MB max stdin

def _project_dir() -> str:
    """Returns the project root directory with validation."""
    # Claude Code always provides CLAUDE_PROJECT_DIR
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR")
    if project_dir and os.path.isdir(project_dir):
        return os.path.realpath(project_dir)
    
    # Fallback: navigate up from hooks directory structure
    current = os.path.realpath(os.getcwd())
    
    # Security: limit path length
    if len(current) > 4096:
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
    
    # Last resort: assume we're in project root
    return current

def _logs_dir() -> str:
    """Creates and returns the logs directory path with path traversal protection."""
    today = datetime.datetime.now().strftime("%Y-%m-%d")
    project_root = os.path.realpath(_project_dir())
    
    # Construct and validate path to prevent traversal attacks
    logs_path = os.path.realpath(os.path.join(project_root, ".claude", "logs", today))
    
    # Security: ensure logs path is within project directory
    try:
        common_path = os.path.commonpath([logs_path, project_root])
        if os.path.realpath(common_path) != os.path.realpath(project_root):
            raise ValueError("Path traversal detected")
    except ValueError:
        raise ValueError("Invalid logs path")
    
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
    
    try:
        with open(path, "a", encoding="utf-8") as f:
            f.write(json.dumps(payload, ensure_ascii=False) + "\n")
    except OSError as e:
        sys.stderr.write(f"[hooks][log_event] error escribiendo log: {e}\n")

def read_stdin_json():
    """Lee stdin y parsea JSON con límite de seguridad."""
    try:
        # Leer con límite real para prevenir DoS
        if hasattr(sys.stdin, 'buffer'):
            raw = sys.stdin.buffer.read(MAX_STDIN_SIZE).decode('utf-8')
        else:
            # Fallback for testing or text mode
            raw = sys.stdin.read(MAX_STDIN_SIZE)
        
        if not raw:
            return {}
        return json.loads(raw)
    except json.JSONDecodeError:
        return {"_json_error": "Invalid JSON format"}
    except Exception:
        return {"_error": "Input processing failed"}

# Cache optimizado sin BatchLogger
class OptimizedAnalysisCache:
    """Cache optimizado con memory management simplificado."""
    
    def __init__(self, ttl: int = CACHE_TTL_SEC, 
                 max_entries: int = CACHE_MAX_ENTRIES, 
                 max_memory_mb: int = CACHE_MAX_MEMORY_MB):
        self.ttl = ttl
        self.max_entries = max_entries
        self.max_memory_bytes = max_memory_mb * 1024 * 1024
        self.cache = OrderedDict()
        self._lock = threading.RLock()
        
        # Estadísticas simplificadas
        self.hits = 0
        self.misses = 0
        self.memory_bytes = 0
        
        # Cleanup timer
        self._cleanup_timer = None
        self._start_cleanup_timer()
    
    def _start_cleanup_timer(self):
        """Inicia timer de cleanup automático."""
        if self._cleanup_timer:
            self._cleanup_timer.cancel()
        
        self._cleanup_timer = threading.Timer(CACHE_CLEANUP_INTERVAL_SEC, self._cleanup_expired)
        self._cleanup_timer.daemon = True
        self._cleanup_timer.start()
    
    def _cleanup_expired(self):
        """Cleanup de entradas expiradas."""
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
                        self.memory_bytes -= entry.get("memory_size", 0)
        except Exception as e:
            # Log cleanup errors for debugging
            try:
                log_event("errors.jsonl", {"event": "cache_cleanup_error", "error": str(e)})
            except:
                pass
        finally:
            self._start_cleanup_timer()
    
    def _estimate_memory_size(self, obj: Any) -> int:
        """Estima tamaño en memoria de objeto (optimizado con sys.getsizeof)."""
        try:
            # Use Python's built-in memory size calculation
            size = sys.getsizeof(obj)
            
            # For containers, add size of contained objects (with recursion limit)
            if isinstance(obj, dict) and len(obj) < 100:  # Limit recursion for large dicts
                size += sum(sys.getsizeof(k) + sys.getsizeof(v) for k, v in obj.items())
            elif isinstance(obj, (list, tuple)) and len(obj) < 100:  # Limit recursion for large lists
                size += sum(sys.getsizeof(item) for item in obj)
                
            return size
        except (TypeError, RecursionError):
            # Fallback for objects that don't support getsizeof
            return len(str(obj)) if obj else 0
    
    def _enforce_memory_limit(self):
        """Fuerza límites de memoria eliminando entradas LRU."""
        while (len(self.cache) > self.max_entries or 
               self.memory_bytes > self.max_memory_bytes):
            
            if not self.cache:
                break
                
            # Eliminar entrada más antigua (LRU)
            oldest_key = next(iter(self.cache))
            entry = self.cache.pop(oldest_key)
            self.memory_bytes -= entry.get("memory_size", 0)
    
    def get(self, content_hash: str) -> Optional[Dict[str, Any]]:
        """Obtiene entrada del cache."""
        with self._lock:
            if content_hash not in self.cache:
                return None
            
            entry = self.cache[content_hash]
            current_time = time.time()
            
            # Verificar expiración
            if current_time - entry["cached_at"] >= self.ttl:
                self.cache.pop(content_hash)
                self.memory_bytes -= entry.get("memory_size", 0)
                return None
            
            # Mover al final para LRU (touch)
            self.cache.move_to_end(content_hash)
            
            self.hits += 1
            return entry["result"]
    
    def set(self, content_hash: str, result: Dict[str, Any]):
        """Almacena resultado en cache."""
        with self._lock:
            # Calcular tamaño en memoria
            memory_size = self._estimate_memory_size(result)
            
            # Si ya existe, remover entrada anterior
            if content_hash in self.cache:
                old_entry = self.cache.pop(content_hash)
                self.memory_bytes -= old_entry.get("memory_size", 0)
            
            # Crear nueva entrada
            entry = {
                "result": result,
                "cached_at": time.time(),
                "memory_size": memory_size
            }
            
            self.cache[content_hash] = entry
            self.memory_bytes += memory_size
            
            # Enforcer límites
            self._enforce_memory_limit()
    
    def get_or_analyze(self, content: str, analyzer: Callable) -> Dict[str, Any]:
        """Método principal optimizado para obtener o analizar contenido."""
        # Usar hash seguro siempre
        content_hash = hashlib.sha256(content.encode()).hexdigest()[:CONTENT_HASH_LENGTH]
        
        # Intentar cache primero
        cached = self.get(content_hash)
        if cached is not None:
            # Log cache hit directamente
            log_event("performance.jsonl", {
                "event": "cache_hit",
                "content_hash": content_hash,
                "content_size": len(content),
                "hit_rate": (self.hits / (self.hits + self.misses) * 100) if (self.hits + self.misses) > 0 else 0
            })
            return cached
        
        # Cache miss - ejecutar análisis
        start_time = time.perf_counter()
        result = analyzer(content)
        analysis_time_ms = (time.perf_counter() - start_time) * 1000
        
        # Almacenar en cache
        self.set(content_hash, result)
        self.misses += 1
        
        # Log cache miss directamente
        log_event("performance.jsonl", {
            "event": "cache_miss",
            "content_hash": content_hash,
            "content_size": len(content),
            "analysis_time_ms": analysis_time_ms,
            "hit_rate": (self.hits / (self.hits + self.misses) * 100) if (self.hits + self.misses) > 0 else 0
        })
        
        return result
    
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
                ttl=CACHE_TTL_SEC, 
                max_entries=CACHE_MAX_ENTRIES, 
                max_memory_mb=CACHE_MAX_MEMORY_MB
            )
        return _global_cache

# Performance tracking
@contextmanager
def track_performance(operation_name: str, **context):
    """Context manager para tracking automático de performance."""
    start_time = time.perf_counter()
    start_memory = 0
    
    if psutil:
        try:
            start_memory = psutil.Process().memory_info().rss / 1024 / 1024
        except:
            pass
    
    correlation_id = str(uuid.uuid4())[:8]
    
    try:
        yield correlation_id
    finally:
        end_time = time.perf_counter()
        duration_ms = (end_time - start_time) * 1000
        
        end_memory = 0
        if psutil:
            try:
                end_memory = psutil.Process().memory_info().rss / 1024 / 1024
            except:
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
        if duration_ms > PERFORMANCE_THRESHOLD_MS:
            log_event("alerts.jsonl", {
                "level": "warning",
                "message": f"Hook '{operation_name}' took {duration_ms:.2f}ms (>{PERFORMANCE_THRESHOLD_MS}ms threshold)",
                "operation": operation_name,
                "duration_ms": duration_ms
            })

# Función de conveniencia para usar el cache global
def get_cached_analysis(content: str, analyzer: Callable) -> Dict[str, Any]:
    """Usar el cache global para análisis."""
    return _get_global_cache().get_or_analyze(content, analyzer)

# Función simple para logging de decisiones AI
def log_decision(decision: str, reason: str, confidence: str = "high"):
    """Log simple de decisiones AI - minimalista y efectivo."""
    log_event("decisions.jsonl", {
        "decision": decision,
        "reason": reason,
        "confidence": confidence
    })