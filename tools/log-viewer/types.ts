// Shared logging types for frontend and backend
export interface LogEntry {
  '@timestamp': string;
  '@service': 'frontend' | 'backend' | 'auth';
  '@traceId': string;
  '@sessionId'?: string;
  '@environment': string;
  level: 'error' | 'warn' | 'info' | 'debug';
  type: string;
  message?: string;
  request?: {
    url: string;
    method: string;
    headers?: Record<string, string>;
    body?: any;
  };
  response?: {
    status: number;
    statusText?: string;
    headers?: Record<string, string>;
    body?: any;
    duration?: number;
  };
  error?: {
    message: string;
    stack?: string;
    response?: any;
  };
  // GraphQL specific
  operation?: string;
  query?: string;
  variables?: any;
  // Frontend specific
  url?: string;
  userAgent?: string;
  // Additional metadata
  [key: string]: any;
}