#!/usr/bin/env python3
import unittest, tempfile, os, sys, json, io
from unittest.mock import patch, mock_open

# Add hooks to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'hooks'))

import common

class TestHooksCommon(unittest.TestCase):
    
    def setUp(self):
        """Setup test environment"""
        self.temp_dir = tempfile.mkdtemp()
        
    def tearDown(self):
        """Cleanup"""
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)
    
    def test_read_stdin_json_valid(self):
        """Test valid JSON parsing"""
        with patch('sys.stdin', io.StringIO('{"test": "data"}')):
            result = common.read_stdin_json()
            self.assertEqual(result, {"test": "data"})
    
    def test_read_stdin_json_invalid_no_raw_data(self):
        """Test invalid JSON doesn't expose raw data"""
        with patch('sys.stdin', io.StringIO('invalid json')):
            result = common.read_stdin_json()
            self.assertIn("_json_error", result)
            self.assertNotIn("_raw", result)  # Security fix validation
    
    def test_read_stdin_json_empty(self):
        """Test empty input"""
        with patch('sys.stdin', io.StringIO('')):
            result = common.read_stdin_json()
            self.assertEqual(result, {})
    
    @patch.dict(os.environ, {'CLAUDE_PROJECT_DIR': '/fake/project'})
    @patch('os.path.isdir')
    def test_project_dir_env_var(self, mock_isdir):
        """Test project dir from environment"""
        mock_isdir.return_value = True
        result = common._project_dir()
        self.assertEqual(result, '/fake/project')
    
    @patch('os.path.commonpath')
    @patch('os.path.realpath')
    def test_logs_dir_path_traversal_protection(self, mock_realpath, mock_commonpath):
        """Test path traversal protection"""
        mock_realpath.side_effect = lambda x: x
        mock_commonpath.side_effect = ValueError("Path traversal detected")
        
        with self.assertRaises(ValueError):
            common._logs_dir()
    
    def test_log_event_no_hostname_exposure(self):
        """Test hostname not exposed in logs"""
        with tempfile.TemporaryDirectory() as temp_dir:
            test_file = os.path.join(temp_dir, 'test.jsonl')
            
            with patch('common._logs_dir', return_value=temp_dir):
                common.log_event('test.jsonl', {'test': 'data'})
            
            with open(test_file) as f:
                logged = json.loads(f.read())
                self.assertNotIn('hostname', logged)  # Security fix validation
                self.assertIn('timestamp', logged)
                self.assertIn('pid', logged)
    
    def test_log_decision_no_user_tracking(self):
        """Test user tracking removed"""
        with tempfile.TemporaryDirectory() as temp_dir:
            test_file = os.path.join(temp_dir, 'decisions.jsonl')
            
            with patch('common._logs_dir', return_value=temp_dir):
                common.log_decision('test_decision', 'test_reason')
            
            with open(test_file) as f:
                logged = json.loads(f.read())
                self.assertNotIn('user_context_hash', logged)  # Security fix validation
                self.assertEqual(logged['decision'], 'test_decision')
    
    def test_cache_functionality(self):
        """Test cache basic operations"""
        cache = common.OptimizedAnalysisCache(ttl=60, max_entries=10, max_memory_mb=1)
        
        # Mock analyzer
        def mock_analyzer(content):
            return {'analyzed': len(content)}
        
        # Test cache miss
        result1 = cache.get_or_analyze('test content', mock_analyzer)
        self.assertEqual(result1['analyzed'], 12)
        
        # Test cache hit
        result2 = cache.get_or_analyze('test content', mock_analyzer)
        self.assertEqual(result1, result2)
        
        # Verify hit/miss counters
        self.assertEqual(cache.hits, 1)
        self.assertEqual(cache.misses, 1)
    
    def test_cache_uses_secure_hash(self):
        """Test cache uses SHA256 instead of hash()"""
        cache = common.OptimizedAnalysisCache()
        
        def mock_analyzer(content):
            return {'test': True}
        
        with patch('hashlib.sha256') as mock_sha256:
            mock_sha256.return_value.hexdigest.return_value = 'abcd1234567890'
            cache.get_or_analyze('test', mock_analyzer)
            mock_sha256.assert_called()  # Validate secure hash usage
    
    def test_performance_tracking(self):
        """Test performance tracking context manager"""
        with tempfile.TemporaryDirectory() as temp_dir:
            perf_file = os.path.join(temp_dir, 'performance.jsonl')
            
            with patch('common._logs_dir', return_value=temp_dir):
                with common.track_performance('test_operation', test_param='value') as correlation_id:
                    self.assertTrue(len(correlation_id) == 8)
            
            # Verify performance log
            with open(perf_file) as f:
                logged = json.loads(f.read())
                self.assertEqual(logged['operation'], 'test_operation')
                self.assertEqual(logged['test_param'], 'value')
                self.assertIn('duration_ms', logged)
    
    def test_session_context_initialization(self):
        """Test session context management"""
        context = common.init_session_context('test_session')
        self.assertEqual(context['session_id'], 'test_session')
        self.assertTrue(len(context['correlation_id']) == 8)
    
    @patch.dict(os.environ, {'CLAUDE_SESSION_ID': 'env_session'})
    def test_session_context_from_env(self):
        """Test session ID from environment"""
        context = common.init_session_context()
        self.assertEqual(context['session_id'], 'env_session')

if __name__ == '__main__':
    unittest.main(verbosity=2)