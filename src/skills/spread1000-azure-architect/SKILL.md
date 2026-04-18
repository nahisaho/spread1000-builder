---
name: spread1000-azure-architect
description: |
  Designs a research infrastructure architecture on Microsoft Azure based on the
  research plan. Generates a comprehensive design document including GPU clusters,
  ML pipelines, data storage, and network configuration. References Microsoft Learn
  MCP for optimal configurations.
  Use when user wants to design Azure構成 (Azure architecture), build GPUクラスタ
  (GPU cluster), or design MLパイプライン (ML pipeline).
---

# Azure Architect

Design the optimal Microsoft Azure architecture for the research plan.

## Use This Skill When

- The research plan is finalized and it's time to design the Azure research infrastructure
- GPU cluster or ML pipeline configuration needs to be determined
- Data storage and network configuration need optimization

## Required Inputs

- `output/phase0-research-plan.md` (research plan)
- Estimated computational resources needed for the research
- Data type, size, and access patterns

## Workflow

1. **Research Plan Analysis**: Extract computational and data requirements
2. **Azure Service Selection**: Select optimal services from the following perspectives:
   - Read `references/azure-research-services.md` when selecting Azure services
   - Compute: Azure Machine Learning, Azure Batch, Azure HPC (NC/ND series)
   - Storage: Azure Blob Storage, Azure Data Lake, Azure NetApp Files
   - Data Processing: Azure Databricks, Azure Synapse Analytics
   - AI Services: Azure OpenAI Service, Azure AI Services
   - Network: Azure Virtual Network, ExpressRoute
3. **Architecture Design**:
   - Create component diagram (Mermaid)
   - Create data flow diagram
   - Define security and compliance requirements
   - Design availability and scalability
4. **WAF Best Practices Validation**: Validate the design against the 5 pillars of Azure Well-Architected Framework
   - Read `references/waf-checklist.md` for the full checklist
   - Reliability: Availability zones, checkpoints, recovery strategy
   - Security: Network isolation, Private Endpoint, Managed Identity, RBAC
   - Cost Optimization: Autoscale, Spot VM, storage tiering
   - Operational Excellence: IaC, MLOps pipeline, monitoring
   - Performance Efficiency: GPU utilization, region placement, IOPS
   - `fetch` WAF Service Guides for each service to verify latest recommended configurations
5. **Design Document Generation**: Save as `output/phase1-azure-architecture.md`
   - Reuse `assets/architecture-template.md` when producing the design document
   - Include WAF validation results as a "WAF Best Practices Compliance" section in the design document
6. **Final Verification**: Confirm the design meets research plan requirements
7. **Auto-trigger Phase 1b**: After saving the design document and obtaining user approval, automatically invoke `spread1000-diagram-generator` to generate system architecture diagrams from the design.
   - This ensures diagrams are available for the proposal's 参考）図 section before Phase 2 (cost estimation)
   - Do NOT wait for a separate user request — proceed directly to diagram generation

## Deliverables

- `output/phase1-azure-architecture.md`: Azure architecture design document (complete)
- Architecture diagram (embedded in Mermaid format within the design document)

## Quality Gates

- [ ] All computational requirements from the research plan are mapped to Azure resources
- [ ] GPU specifications are suitable for the required model size and training volume
- [ ] Data storage capacity and throughput meet research data requirements
- [ ] Security (RBAC, network isolation, encryption) is designed
- [ ] Scalability (autoscale, Spot VM utilization) is considered
- [ ] Region selection rationale is documented
- [ ] Validated against the WAF 5-pillar checklist (see `references/waf-checklist.md`)
- [ ] WAF Service Guide configuration recommendations are reflected in the design

## Gotchas

- Azure GPU VMs (NC series, ND series) have significantly different availability by region. Always verify availability in Japan East
- Azure Machine Learning compute clusters and compute instances serve different purposes. Use clusters for training, instances for development
- Select Azure Blob Storage access tiers (Hot/Cool/Archive) appropriately based on data access frequency
- Check whether Azure Sponsorship / Academic Grant for academic research is available

## Security Guardrails

- When handling medical data (DICOM, FHIR, genomics), Private Endpoint and RBAC for Azure Health Data Services are mandatory
- For research involving personal or sensitive data, include Azure TRE Restricted Workspace + Airlock in the design
- Storage defaults to encryption at rest (SSE) + TLS 1.2+. Specify whether customer-managed keys (CMK) are required
- Manage secrets with Key Vault. Never hardcode connection strings or keys in templates or code

## Validation Loop

1. Generate the design document
2. **Research Requirements Check**:
   - Research plan computational requirements coverage ≥ 100%
   - Selected VM size GPU memory is sufficient for training
   - Storage IOPS meets data processing requirements
3. **WAF Best Practices Check**:
   - Verify all items on the 5-pillar checklist in `references/waf-checklist.md`
   - `fetch` the WAF Service Guide for each adopted Azure service:
     - Azure Machine Learning: `https://learn.microsoft.com/azure/well-architected/service-guides/azure-machine-learning`
     - Azure Blob Storage: `https://learn.microsoft.com/azure/well-architected/service-guides/azure-blob-storage`
     - Azure Key Vault: `https://learn.microsoft.com/azure/well-architected/service-guides/azure-key-vault`
     - Other adopted services: search at `https://learn.microsoft.com/azure/well-architected/service-guides/`
   - Cross-check each item in the "Configuration recommendations" section against the design
4. If any check fails:
   - Re-select VM size or services
   - Modify design according to WAF Service Guide configuration recommendations
   - Re-verify
5. Finalize deliverables only after all gates pass
