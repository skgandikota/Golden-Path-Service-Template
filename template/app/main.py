"""
Golden Path Service Template — Hello Platform API

Every service bootstrapped from this template starts here.
This tiny API demonstrates that all services are structured identically
before teams add their own business logic.
"""

from fastapi import FastAPI

app = FastAPI(
    title="Hello Platform Service",
    description="A Golden Path starter service — secure, observable, container-ready.",
    version="1.0.0",
)


@app.get("/", tags=["health"])
def root():
    """Root health-check endpoint."""
    return {"status": "ok", "service": "hello-platform"}


@app.get("/health", tags=["health"])
def health():
    """Liveness probe for Kubernetes."""
    return {"status": "healthy"}


@app.get("/hello", tags=["platform"])
def hello():
    """Sample platform endpoint — replace with your business logic."""
    return {"message": "Hello, Platform! 👋", "template": "golden-path-service-template"}
