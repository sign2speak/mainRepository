#  Sign2Speak

**An AI-Powered Sign Language Recognition & Translation System**

---

##  Overview

**Sign2Speak** is an intelligent system designed to bridge the communication gap between **deaf and hearing individuals** by recognizing sign language gestures and translating them into understandable text or actions in real time.

The project integrates:

* **Frontend application** for user interaction
* **Backend services** for processing and orchestration
* **Machine Learning models** for sign recognition and inference

All components are fully integrated into a complete end-to-end pipeline.

---

## Objectives

* Enable real-time recognition of sign language gestures
* Convert gestures into meaningful text or responses
* Provide an accessible and user-friendly interface
* Demonstrate practical use of AI in assistive technology

---

## System Architecture

The system follows a modular architecture:

```
Frontend  →  Backend API  →  ML Inference Engine
   ↑                                  ↓
   ←──────────── Response ────────────
```

* **Frontend** handles user interaction and video/input capture
* **Backend** manages requests, authentication, and ML integration
* **ML Module** processes data and returns predictions

---

## Machine Learning Component

* Custom-trained model for sign/gesture recognition
* Supports predefined sign labels
* Integrated inference pipeline (no manual steps)
* Optimized for real-time or near real-time predictions

---

## Backend Features

* RESTful APIs for frontend communication
* Secure environment-based configuration
* ML inference integration
* Scalable and modular design

---

## Frontend Features

* Simple and accessible user interface
* Real-time interaction with backend services
* Clear display of recognition results
* Designed for usability and clarity

---

## Project Structure

```
sign2speak/
├── frontend/              # UI / client-side code
├── sign2speak-backend/    # Backend services
├── ml/                    # Machine learning models & logic
├── assets/                # Static resources
├── README.md
└── .gitignore
```

---

## Getting Started

### Prerequisites

* Node.js (for backend)
* Python (for ML services)
* Flutter / Web stack (for frontend)
* Git

---

### Clone the Repository

```bash
git clone https://github.com/your-username/sign2speak.git
cd sign2speak
```

---

### Environment Setup

**Important:**
Sensitive files such as service account keys and environment variables are **not included** in the repository.

Create your own:

```bash
.env
serviceAccount.json
```

Refer to `.env.example` (if provided).

---

## Current Status

* Frontend, backend, and ML fully integrated
* End-to-end workflow functional
* Suitable for FYP demo and evaluation
* Continuous improvements planned

---

## Academic Context

This project is developed as part of a **Final Year Project (FYP)** with a focus on:

* Artificial Intelligence
* Assistive Technology
* Human–Computer Interaction

---

## License

This project is intended for **academic and educational purposes**.

---

## Contributions

Contributions, suggestions, and improvements are welcome.
