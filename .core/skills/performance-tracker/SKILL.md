<skill id="performance-tracker" version="2.0">
<!-- Her analiz zinciri için performans metrikleri toplar ve kaydeder -->
<!-- Kullananlar: orchestrator + tüm agentlar -->

<purpose>
Her /core-analyze başında metrics.json oluşturulur. Her agent kendi bölümünü
doldurur. Zincir bitince orchestrator summary alanlarını hesaplar.
</purpose>

<schema>
  Dosya: core-output/[TICKET-ID]/metrics.json

  Üst düzey alanlar:
  - ticket_id, analysis_type, started_at, completed_at, total_duration_seconds

  agents bölümü — her agent kendi alt bölümünü yazar:
  - interview: started_at, completed_at, duration_seconds, status, estimated_tokens, output_files
  - prd: + iterations, hallucination_rate
  - prd-reviewer: + decisions[], red_count, onay_count
  - codebase-analyst: + hallucination_rate
  - implementation-plan: (standart alanlar)
  - jira-creator: + jira_issues_created, confluence_pages_created, dry_run
  - feedback-collector: + quality_scores{genel, gereksinim_kapsamı, teknik_dogruluk, format_kalitesi}

  summary bölümü (orchestrator doldurur):
  - total_estimated_tokens, total_duration_seconds
  - prd_pass_on_first_review (red_count == 0 ?)
  - reviewer_iterations, overall_quality_score
  - hallucination_rates{prd_brd, impact_analysis}
  - cost_estimate{model, estimated_tokens, estimated_usd}
</schema>

<agent-procedure>
  Başlarken:
  - metrics.json'u oku; kendi bölümünü yükle
  - started_at = şu an; status = "in_progress"

  Biterken:
  - completed_at, duration_seconds, estimated_tokens, status = "completed" yaz
  - Agent'a özgü ek alanları doldur
</agent-procedure>

<token-estimation>
  Agent'lar gerçek token sayısını bilemez; aşağıdaki aralıklarla tahmin eder:

  | İçerik Türü                        | Tahmini Token |
  |------------------------------------|---------------|
  | Kısa brief / özet (&lt; 500 kelime)  | 1.500 – 3.000 |
  | Standart PRD veya BRD              | 4.000 – 8.000 |
  | Epic PRD + BRD                     | 8.000 – 15.000 |
  | Impact analysis                    | 3.000 – 6.000 |
  | Implementation plan                | 5.000 – 10.000 |
  | Jira Creator (çok sayıda issue)    | 4.000 – 8.000 |
  | Review report                      | 2.000 – 4.000 |

  Maliyet formülü (claude-sonnet-4-6):
  estimated_usd = (tokens × 0.4 × 3.0 + tokens × 0.6 × 15.0) / 1_000_000
</token-estimation>

<hallucination-rate>
  Halüsinasyon Doğrulama Özeti'nden:
  hallucination_rate = doğrulanamayan / toplam_kontrol_edilen
  Değer aralığı: 0.0 – 1.0 (ondalık)
</hallucination-rate>

<summary-calculation>
  Orchestrator — tüm zincir bitince hesaplar:
  - total_estimated_tokens = tüm agent estimated_tokens toplamı
  - total_duration_seconds = started_at → completed_at farkı
  - prd_pass_on_first_review = (red_count == 0) ? true : false
  - reviewer_iterations = red_count + onay_count
  - overall_quality_score = feedback-collector.quality_scores.genel
</summary-calculation>

<rules>
  <r>metrics.json dosyası her /core-analyze başında sıfırdan oluşturulur</r>
  <r>Her agent kendi altbölümünü yazar; başka agent'ın alanına dokunmaz</r>
  <r>dry_run: true ise jira-creator bölümüne dry_run: true ekle; sayıları 0 bırak</r>
  <r>Tokeni tahmin et — kesin değer yok; yukarıdaki tablo kılavuzdur</r>
</rules>

</skill>
