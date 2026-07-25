# Risk Registry & Mitigation - Logistics Vision AI

This document catalogs high-priority engineering, operational, and performance risks, mapping them to actionable technical mitigations.

---

## 1. Technical Risk Matrix

| Risk ID | Risk Category | Risk Description | Criticality | Mitigation Strategy |
| :--- | :--- | :--- | :--- | :--- |
| **R-01** | **Operational** | **Deep Warehouse Network Blackouts**: Zero internet connectivity for entire shifts. | **High** | Implement a local synchronization outbox database table. Store all images and carton layers offline; auto-sync in batches when network connectivity is re-established. |
| **R-02** | **Hardware** | **Mobile Thermal Throttling**: Continuous camera usage and on-device YOLO inference runs NPUs/CPUs hot, causing UI lag or system shut-down. | **High** | Limit live AI inference frame rate during scanning. Run object detection on target frames (e.g., 5-10 FPS instead of 30 FPS) while keeping the visual video preview at 60 FPS. |
| **R-03** | **Data Integrity** | **Out-of-Order Synchronization**: Multiple devices editing the same truck data leading to state overwrite conflict. | **Medium** | Use immutable event logs (Append-Only) for layer creation. Use a composite primary key `(truck_id, layer_number)` to block concurrent writes to the same layer. |
| **R-04** | **AI Accuracy** | **Carton Occlusion and High Error Rates**: Cartons partially hidden behind columns or poorly stacked skew counting. | **High** | Introduce an interactive edit mode in the Presentation Layer, letting operators touch to add missing detections or swipe to remove false positives prior to saving the layer. |
| **R-05** | **Security** | **Data Theft from Lost Devices**: Offline database containing logistics records read by unauthorized users. | **Medium** | Apply SQLCipher database encryption using dynamic keys generated and stored in secure enclaves (iOS Keychain / Android Keystore). |
| **R-06** | **Operational** | **Low-Quality Scan in Low Light**: Poorly lit truck trailers result in massive false-negatives. | **Medium** | Develop a lighting heuristic checking average pixel brightness in real time. Flash a UI alert suggesting the operator toggle the flashlight overlay control. |

---

## 2. Risk Mitigation Protocols

### Conflict Resolution Workflow (Sync Conflicts)
```
          Incoming Local Database Sync Event
                        |
                        v
        Does (TruckID, LayerNumber) exist in Cloud?
             /                     \
          [No]                     [Yes]
           /                         \
    Insert directly                   \
                               Operator Identity Check
                              /                       \
                      [Same Operator]             [Different Operator]
                            /                            \
              Reject upload: Already Synced        Raise Sync Error / Alert
                                                   Create Audit Exception log
```
*   **Protocol**: Since a single truck layer is typically loaded by a single operator, conflicts are minimised by restricting layer creation to the assigned worker ID. If another worker attempts to update a layer, it triggers a warning flag requiring supervisor override.
