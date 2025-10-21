# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a voiceprint recognition API service based on the 3D-Speaker model from ModelScope. It provides speaker registration, identification, and deletion capabilities using deep learning-based voice embeddings. The service is built with FastAPI and uses MySQL for storing voiceprint features.

## Key Architecture Components

### Service Layers
1. **API Layer** (`app/api/v1/`): FastAPI routers handling HTTP endpoints
   - `/voiceprint/register` - Register new speaker voiceprints
   - `/voiceprint/identify` - Identify speaker from audio
   - `/voiceprint/{speaker_id}` - Delete speaker voiceprint
   - `/voiceprint/health` - Health check endpoint

2. **Service Layer** (`app/services/voiceprint_service.py`): Core business logic
   - Manages the 3D-Speaker model pipeline
   - Handles audio feature extraction and comparison
   - Implements similarity scoring with cosine similarity
   - Thread-safe model inference with locking

3. **Database Layer** (`app/database/`): SQLite integration
   - `connection.py`: Thread-safe SQLite connection management
   - `voiceprint_db.py`: CRUD operations for voiceprint storage
   - Stores speaker embeddings as BLOB in SQLite
   - Automatic database initialization on startup

4. **Model Integration**: Uses ModelScope's `speech_campplus_sv_zh-cn_3dspeaker_16k` model
   - CPU-only mode (optimized for deployment, no CUDA dependencies)
   - Model warmup on startup for performance
   - Thread-safe inference with pipeline lock

## Development Commands

### Environment Setup
```bash
# Create conda environment
conda create -n voiceprint-api python=3.10 -y
conda activate voiceprint-api

# Install PyTorch CPU version first
pip install torch==2.2.2+cpu torchaudio==2.2.2+cpu -f https://download.pytorch.org/whl/torch_stable.html

# Install other dependencies
pip install -r requirements.txt
```

### Database Setup
SQLite database is automatically created on first run. No manual setup required.

### Configuration
Copy `voiceprint.yaml` to `data/.voiceprint.yaml` and configure:
- SQLite database path (default: data/voiceprint.db)
- Server host/port (default: 0.0.0.0:8005)
- Authorization token (auto-generated if empty)

### Running the Service
```bash
# Development mode (with auto-reload)
python -m app.main

# Production mode
python start_server.py

# Docker deployment
docker-compose up -d
```

### API Documentation
After starting, access Swagger UI at: `http://localhost:8005/voiceprint/docs`

## Core Workflows

### Audio Processing Pipeline
1. Audio file uploaded as WAV format
2. `audio_processor.ensure_16k_wav()` converts to 16kHz sampling rate
3. Temporary files stored in `tmp/` directory
4. Model extracts 512-dimensional embedding vector
5. Vector stored in SQLite as BLOB or compared for identification

### Speaker Identification Flow
1. Extract embedding from input audio
2. Retrieve candidate speaker embeddings from database
3. Calculate cosine similarity scores
4. Return speaker with highest score above threshold (default: 0.2)

### Authentication
All endpoints require Bearer token authentication via `Authorization` header. Token is configured in `data/.voiceprint.yaml` or auto-generated.

## Important Design Decisions

1. **Single Worker Process**: Service runs with `workers=1` to avoid loading multiple model instances in memory
2. **Model Warmup**: Pre-runs inference on startup to avoid cold start delays
3. **Thread Safety**: Uses `threading.Lock()` for both SQLite database and model pipeline access
4. **Audio Normalization**: All audio converted to 16kHz WAV before processing
5. **Embedding Storage**: 512-dimensional float32 vectors stored as binary in SQLite BLOB
6. **SQLite Optimizations**: WAL mode for better concurrency, memory-mapped I/O for performance

## Testing Considerations

- Test with various audio formats and sampling rates
- Verify thread safety with concurrent requests
- Monitor memory usage with model loaded
- Test similarity threshold tuning for accuracy/recall trade-offs
- Ensure proper cleanup of temporary audio files

## Performance Notes

- First inference after startup may be slower (despite warmup)
- CPU-only PyTorch reduces package size by ~1.5GB
- SQLite database queries optimized with speaker_id indexing
- SQLite WAL mode enables better read concurrency
- Temporary files cleaned up automatically after processing
- No network latency for database operations (local file-based)
- CPU inference is adequate for real-time voiceprint recognition
- Docker image size reduced by ~50% with CPU-only configuration