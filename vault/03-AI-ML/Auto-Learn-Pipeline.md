# Auto-Learn Pipeline Design

> **Status:** Draft | **Phase:** 4

---

## Concept

Auto-learn means the system continuously **improves its models and behavior** from production signals — user interactions, system telemetry, and outcome feedback — without full manual retraining cycles.

## Feedback Loop Architecture

```
Production Traffic
       │
       ▼
┌─────────────────┐
│  Data Capture   │  ← OpenTelemetry traces + custom events
│  (Kafka topics) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Feature Store  │  ← Feast (online + offline store)
│                 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Eval Engine    │  ← Arize AI / WhyLabs
│  (drift detect) │    Scores: accuracy, latency, bias
└────────┬────────┘
         │  drift detected?
         ▼
┌─────────────────┐
│  Retrain Trigger│  ← GitHub Actions workflow / Airflow DAG
│                 │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Model Registry │  ← MLflow — versioned, tagged, auditable
│                 │
└────────┬────────┘
         │  shadow test passes?
         ▼
┌─────────────────┐
│  Canary Deploy  │  ← ArgoCD rollout (5% → 20% → 100%)
│                 │
└─────────────────┘
```

## Auto-Learn Signals

| Signal Type | Example | Action |
|------------|---------|--------|
| User feedback | Thumbs up/down on AI response | Fine-tune preference |
| Implicit signal | Click-through, time-on-page | Relevance scoring |
| System metric | Error rate on AI output | Quality gate trigger |
| Data drift | Input distribution shift | Retrain alert |
| Concept drift | Model accuracy degradation | Full retrain |

## For LLM (Claude) Auto-Learn

Since Claude cannot be fine-tuned (it's an API), "auto-learn" for LLM means:
- **Prompt evolution:** Structured A/B testing of system prompts, auto-selecting winners
- **RAG refinement:** Automatic re-chunking and re-indexing of Qdrant vector DB based on retrieval quality scores
- **Memory updates:** Claude Agent maintains a production memory store of known good/bad patterns

---

*See: ADR-XXX — ML Platform Selection (MLflow vs Vertex AI)*
