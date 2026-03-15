---
mode: agent
description: 'CORE — Jira board keşfi: Mevcut Jira board''larını sorgulayıp domain-context.yaml collaborating_boards alanını doldur'
---

#file:.core/agents/setup.agent.md

Atlassian MCP araçlarını kullanarak mevcut Jira board'larını listele.
Her board için: proje kodu, ekip adı ve amacını tespit et.
Kullanıcıyla hangi board'ların collaborating_boards'a ekleneceğini onayla.
Onaylananları aktif domain'in domain-context.yaml → collaborating_boards alanına yaz.
