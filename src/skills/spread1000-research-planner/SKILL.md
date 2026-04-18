---
name: spread1000-research-planner
description: |
  Formulates an AI for Science research plan. Proposes how to integrate AI into the
  researcher's domain through web research and literature survey, and generates a
  concrete 研究計画書 (research plan document).
  Use when user doesn't know how to apply AI to their 研究テーマ (research theme),
  wants to create a 研究プラン (research plan), or wants to learn about
  AI for Science latest trends (最新動向).
---

# Research Planner

Formulate the optimal AI-powered research plan for the researcher's domain.

## Use This Skill When

- The research theme is decided but the user doesn't know how to leverage AI
- The user wants to survey AI for Science success stories and latest trends
- The user wants to create a 研究計画書 for SPReAD application

## Required Inputs

- Researcher's domain (e.g., materials science, life science, meteorology)
- Research theme or problem overview
- Current research methods / data overview (optional)

## Workflow

1. **Hearing**: Confirm the researcher's field, theme, and current challenges
2. **Web Research**: Investigate the following:
   - AI for Science success stories in the same field (domestic and international)
   - Applicable AI/ML methods (deep learning, reinforcement learning, generative AI, simulation, etc.)
   - Available datasets and computational infrastructure
   - Latest policies from MEXT (文部科学省) AI for Science promotion committee
3. **AI Strategy Formulation**:
   - Map AI methods to research challenges
   - Clarify expected outcomes and breakthroughs
   - Estimate required computational resources (GPU, storage, network, etc.)
4. **Research Plan Generation**: Save as `output/{project-name}/phase0-research-plan.md`
   - Reuse `assets/research-plan-template.md` when producing the research plan
5. **Review**: Verify technical feasibility of the research plan

## Deliverables

- `output/{project-name}/phase0-research-plan.md`: AI-powered research plan (complete)
- `output/{project-name}/phase0-research-survey.md`: Web research results summary

## Quality Gates

- [ ] Mapping between research theme and AI methods is clearly described
- [ ] 3 or more related case studies are cited
- [ ] Required computational resources are quantitatively estimated
- [ ] Research schedule (milestones) is included
- [ ] Novelty and innovativeness in the AI for Science context is explained

## Gotchas

- AI method selection strongly depends on research data characteristics. Always confirm data format (images, time series, text, 3D structures, etc.)
- Do not reflect overblown expectations like "AI can do anything" in the research plan. Explicitly state technical constraints
- Compute resource estimates must be concretely calculated from training data size, model scale, and number of training iterations
- The appropriate framework (PyTorch/TensorFlow/JAX, etc.) varies by research field

## Validation Loop

1. Generate the research plan
2. Check:
   - Is the mapping between AI methods and research challenges logical?
   - Are compute resource estimates realistic?
   - Is the schedule feasible?
3. If any check fails:
   - Identify and fix the relevant section
   - Obtain supplementary information via web research
   - Re-verify
4. Finalize deliverables only after all gates pass
