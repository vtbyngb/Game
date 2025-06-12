# Game
LUA Engine Game Repository

# Server-Client Architecture
This project implements a client-authoritative architecture with server-side validation. In this system, the client initiates and handles state changes, while the server is responsible for validating those actions—either approving or rejecting them.

This design choice was made to offload heavy processing from the server, helping reduce network congestion and latency. The result is a more efficient, responsive experience. To maintain security and integrity, the server backend includes validation logic and protections against script injection attempts.
