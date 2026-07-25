# Code Style Guide - Logistics Vision AI

This document outlines the visual structure, layout conventions, and programming patterns expected throughout the codebase.

---

## 1. Clean Architecture Separation
Keep code strictly segregated to prevent coupling:
*   **No UI dependencies in Domain Layer**: The `domain/` layer must contain pure Dart code. Importing `package:flutter/material.dart` or state managers here is strictly prohibited.
*   **Use Interface Isolation**: Controllers must communicate with repositories via abstract classes defined in the domain layer, not concrete database helper classes.

---

## 2. Naming Conventions
*   **Files**: Lowercase snake_case (e.g. `truck_repository_impl.dart`).
*   **Classes & Types**: UpperCamelCase (e.g. `DriftStorageService`).
*   **Methods & Variables**: lowerCamelCase (e.g. `calculateRunningTotal`).
*   **Providers (Riverpod)**: Suffix with `Provider` (e.g. `activeTruckListProvider`).

---

## 3. Comments and Documentation
*   **Avoid Redundant Comments**: Do not write comments explaining *what* a simple statement does.
*   **Document Complex Logic**: Explain the *why* behind algorithms, hardware limitations, or performance compromises.
*   **Public API Documentation**: Use triple slash `///` comments to generate documentation on public classes, exceptions, and models.
