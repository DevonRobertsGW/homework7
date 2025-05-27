1. Application-level hardening

	Hardcoded passwords were removed, replaced with the mandatory environment variable ('PASSWORD'), and secret externalization was enforced.
	Input validation introduced strict validation functions for IP addresses and arithmetic expressions to prevent injection attacks. A secure
	AST-based arithmetic parser replaced eval(), which only permits allowed operations. The configured Flask app was also bound to '127.0.0.1' 
	rather than '0.0.0.0' to limit exposure to local traffic.

2. Docker Hardening
	
	To reduce the attack surface and keep everything as light as possible, a minimal base image of Python 3.11-slim was used. Build stage separation
	was implemented to keep the runtime containers clean. 'flaskuser' was introduced to drop the root privileges inside the container. HEALTHCHECK 
	was also implemented to detect app failure. .dockerignore was also introduced to exclude unnecessary files, like .env, to minimize the build.

3. Docker Compose Enhancements

	mem_limit and pids_limit prevent resource exhaustion. Enabled read-only for filesystem lockdown and no-new-privileges: true to avoid escalation 	privilege to keep the filesystem immutable. Host port exposure was restricted to '127.0.0.1:5000' to block external access. The .env 
	The file was utilized for secrets management.



Vulnerabilities and Mitigation Approach:

Hardcoded default password   |   Enforced external secret via environment variable.
Command injection in '/ping' |   Used 'ipaddress' module for strict IP validation.
'eval()' risks 		     |   Replaced AST validation and safe arithmetic eval.
Lack of DoS protections      |   Added memory and PID limits with Docker Compose.
Root execution in container  |   Dropped privileges by running as a non-root user.



My biggest takeaway from this assignment is learning that containers improve isolation but are not secure by default. Hardening at both the orchestration and container levels is essential. Another lesson I learned is how dangerous eval() can be in Python coding. eval() allows any code to be executed, such as exfiltrating and deleting files, which would be a boon for an attacker should they get access. eval() also has access to built-in functions like open(), exec(), and input(). I also learned that exposing traffic to '0.0.0.0' will expose it to the internet, and that binding to the localhost is best practice. 


References:

Galinkin, E. (2023, March 16). Python’s Eval(): The most powerful function you should never use. | Udacity. Udacity. https://www.udacity.com/blog/2023/03/pythons-eval-the-most-powerful-function-you-should-never-use.html 