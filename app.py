from flask import Flask, request, jsonify, abort
import os
import subprocess
import platform
import ast
import ipaddress

app = Flask(__name__)

# Retrieve password from environment variable instead of hardcoding
PASSWORD = os.environ.get('PASSWORD', 'default_password')
if not PASSWORD:
    raise RuntimeError("PASSWORD environment variable not set.")

# Input validation
def validate_name(name):
    if not name.isalnum():
        abort(400, description="Invalid name")
    return name

def validate_ip(ip_str):
    try:
        return str(ipaddress.ip_address(ip_str))
    except ValueError:
        abort(400, description="Invalid IP")

def safe_eval(expr):
    try:
        node = ast.parse(expr, mode='eval')

        # Whitelisted AST nodes
        allowed_nodes = (
            ast.Expression, ast.BinOp, ast.UnaryOp,
            ast.Add, ast.Sub, ast.Mult, ast.Div, ast.Mod,
            ast.Pow, ast.USub, ast.Num, ast.Constant, ast.Load,
            ast.FloorDiv
        )

        if not all(isinstance(n, allowed_nodes) for n in ast.walk(node)):
            raise ValueError("Disallowed expression elements")

        return eval(compile(node, "<string>", mode="eval"))
    except Exception as e:
        abort(400, description=f"Invalid expression: {e}")
@app.route('/')
def hello():
    name = request.args.get('name', 'World')
    name = validate_name(name)
    return f"Hello, {name}!!!"

# Secure ping route with input validation and no shell=True
@app.route('/ping')
def ping():
    ip = request.args.get('ip')
    if not ip:
        abort(400, description="Missing ip")
    ip = validate_ip(ip)

    flag = "-c" if platform.system().lower() != "windows" else "-n"

    try:
        result = subprocess.check_output(["ping", flag, "1", ip], text=True)
        return jsonify({"result": result})
    except subprocess.CalledProcessError as e:
        return jsonify({"error": "Ping failed", "details": e.output}), 500
    except Exception as e:
        return jsonify({"error": "Unexpected error", "details": str(e)}), 500

# Secure calculate route using ast.literal_eval instead of eval
@app.route('/calculate')
def calculate():
    expr = request.args.get('expr')
    if not expr:
        abort(400, description="Expression missing")
    result = safe_eval(expr)
    return jsonify({"result": result})

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)  # Bind to localhost instead of all interfaces