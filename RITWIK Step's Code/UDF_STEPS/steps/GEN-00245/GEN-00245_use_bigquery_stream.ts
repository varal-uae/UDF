// GEN-00245 — useBigQueryStream: frontend hook to ingest live metric feeds.
// Metric: Telemetry Ingestion Latency · Pass/Fail.
import { useEffect, useState } from "react";

export function useBigQueryStream<T = unknown>(endpoint: string) {
  const [rows, setRows] = useState<T[]>([]);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const es = new EventSource(endpoint);
    es.onmessage = (e) => {
      try { setRows((prev) => [...prev, JSON.parse(e.data) as T]); }
      catch (err) { setError(err as Error); }
    };
    es.onerror = () => setError(new Error("BigQuery stream error"));
    return () => es.close();
  }, [endpoint]);

  return { rows, error };
}
