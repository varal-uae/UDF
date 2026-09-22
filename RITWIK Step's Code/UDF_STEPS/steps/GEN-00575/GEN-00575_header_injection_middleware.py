"""GEN-00575 — HeaderInjectionMiddleware, registered globally in Django settings.
Metric: Middleware Registration Status · Complete/Not Complete.

Add to settings.py:
    MIDDLEWARE = [..., "app.middleware.HeaderInjectionMiddleware"]
"""


class HeaderInjectionMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        response = self.get_response(request)
        response["X-Trace-Id"] = request.META.get("HTTP_X_TRACE_ID", "unset")
        response["X-Content-Type-Options"] = "nosniff"
        return response
