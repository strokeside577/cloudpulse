import pytest
from app import app

def test_health_endpoint():
    client = app.test_client()
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json == {'status': 'healthy'}

def test_get_todos():
    client = app.test_client()
    response = client.get('/api/todo')
    assert response.status_code == 200
    assert response.json == []

def test_create_todo():
    client = app.test_client()
    response = client.post('/api/todo', json={'title': 'Test Todo'})
    assert response.status_code == 201
    assert 'id' in response.json
    assert 'title' in response.json

def test_metrics_endpoint():
    client = app.test_client()
    response = client.get('/metrics')
    assert response.status_code == 200
    assert 'text/plain' in response.content_type
