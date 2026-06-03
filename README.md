# Enterprise Endpoint Event Reporter & Compliance Framework 
### Kurumsal Endpoint Olay Raporlayıcı ve Uyumluluk Çerçevesi

[TR] Bu proje, kurumsal ağdaki Windows istemcilerden gelen karmaşık olay günlüklerini (Event Logs) toplar, kritik donanım/sistem hatalarını analiz eder ve Microsoft Graph API ile MECM/SCCM Baseline mimarilerini kullanarak yönetim ekiplerine anlamlandırılmış raporlar sunar.

[EN] This project collects complex event logs from corporate Windows devices, analyzes critical hardware/system errors, and delivers meaningful insights to IT administration using Microsoft Graph API and MECM/SCCM Baseline architectures.

---

##  Framework Architecture & Options | Seçenekler ve Mimari

[TR] Proje, kurumsal altyapınızın ihtiyaçlarına ve yönetim araçlarınıza göre **3 farklı entegrasyon seçeneği** sunmaktadır:
[EN] The project provides **3 distinct integration options** based on your enterprise infrastructure tools and needs:

| Folder / Klasör | Architecture | Engine / Komut | Target Channels | Reporting Method |
| :--- | :--- | :--- | :--- | :--- |
| **[01-Full-Logs-Version](./01-Full-Logs-Version)** | Standard Intune Remediation | `Get-EventLog` | System | Central Server File Share & Graph API Mail |
| **[02-Critical-Only-Version](./02-Critical-Only-Version)** | Advanced Intune Remediation | `Get-WinEvent` | System, Application, Security | High-Performance Filtered Share & Graph API Mail |
| **[03-SCCM-PowerBI-Compliance](./03-SCCM-PowerBI-Compliance)** | MECM / SCCM Desired State | `Get-WinEvent` | System, Application, Security | SCCM WMI Database & Power BI Dashboard |

<img width="1365" height="784" alt="Architecture Flow" src="https://github.com/user-attachments/assets/306d23d1-82f8-4ac8-a4ff-0d5d4600b68a" />

---

##  Technical Prerequisites & Setup | Teknik Gereksinimler & Kurulum

[TR] Seçtiğiniz versiyona göre aşağıdaki bileşenlerin kurumsal ortamınızda yapılandırılmış olması gerekmektedir:
[EN] Depending on the option chosen, the following components must be configured in your corporate environment:

### 1. Azure App Registration (Microsoft Graph API)
* **API / Permission Name:** `Mail.Send`
* **Type:** Application (Send mail as any user / Uygulama adına mail gönderimi)
* **Admin Consent:** Gerekli / Required

<img width="1368" height="768" alt="API_permissions" src="https://github.com/user-attachments/assets/76e6bd28-4036-4ad5-aa4e-191f67b32fe2" />

### 2. Network Share & Folder Permissions | Ağ Paylaşımı & Klasör Yetkileri
* **Shared Folder Path:** `\\<YOUR_SERVER_NAME>\<YOUR_SHARE_NAME>$`
* **Share Permissions:** `Everyone` veya `Domain Computers` -> Full Control.
* **Security (NTFS) Permissions:** `Domain Computers` grubu için -> `Modify`, `Read & Execute`, `List folder contents`, `Read`, `Write`.

<img width="955" height="1120" alt="shared_folder" src="https://github.com/user-attachments/assets/c6b6da30-0686-487f-b935-b8239b67cf26" />

### 3. Task Scheduler Configuration | Görev Zamanlayıcı Yapılandırması (Version 01 & 02)
* **Trigger (Tetikleyici):** Daily (Günlük), Belirlenen saatte (Örn: 18:00).
* **Action (Eylem):** Start a program
* **Program/script:** `powershell.exe`
* **Add arguments:** `-ExecutionPolicy Bypass -File "C:\<PATH_TO_SCRIPT>\Central-Server-Script.ps1"`

<img width="1078" height="976" alt="task_scheduler" src="https://github.com/user-attachments/assets/fb70df54-73ba-4ce8-b982-4608412fd52d" />

---

##  Deployment Methods | Dağıtım Yöntemleri

### A. Microsoft Intune Proactive Remediations (Version 01 & 02)

<img width="1235" height="848" alt="intune2" src="https://github.com/user-attachments/assets/d86849b0-24e2-4192-ac70-1b8db0404333" />

* **Detection Script:** Intune'un her zaman düzeltme (remediation) aşamasına geçmesini sağlayan `exit 1` mantığını içerir.
* **Run credentials:** No (Runs as SYSTEM account)
* **64-bit PowerShell:** Yes (Required for performance and full access to modern Windows event log providers)
* **Schedule:** Daily, repeats every 1 hour indefinitely.

### B. MECM / SCCM Configuration Baseline (Version 03)
[TR] İstemci loglarını merkezi bir sunucuya kopyalamak yerine doğrudan SCCM Uyumluluk (Compliance) mimarisine gömmek, SQL veritabanı üzerinden çekmek ve Power BI ile raporlamak için bu yöntem kullanılır.
[EN] This method integrates compliance discovery directly into the SCCM Baseline architecture and extracts reports via SQL to feed the Power BI Dashboard, eliminating the need for network file copies.

* **Configuration Item (CI) Type:** Windows PowerShell Discovery Script
* **Compliance Rule Condition:** Output `Equals` -> `Temiz`

<img width="1235" height="848" alt="SCCM Compliance Setup" src="https://github.com/user-attachments/assets/68218e81-2119-48e1-956b-db8871040383" />

---

##  Sample Reports & Outputs | Örnek Rapor Çıktıları

### 📨 Microsoft Graph API E-Posta Özeti (Version 01 & 02)
[TR] Sistem başarıyla çalıştığında, yöneticilere ulaşan mail ve ekindeki sıkıştırılmış (.zip) analiz raporu otomatik olarak iletilir.
[EN] When the system runs successfully, the summary email and its compressed (.zip) analysis report are automatically delivered to the administrators.

<img width="1365" height="784" alt="LAST_RREPOR" src="https://github.com/user-attachments/assets/e978263a-dece-4973-aef8-35cea855da0f" />

---

##  SIEM vs. This Framework
[TR] Kurumsal SIEM çözümleri (Microsoft Sentinel, Splunk vb.) ingestion (veri toplama) hacmine göre ücretlendirilir. Bu framework ise tamamen mevcut Microsoft 365 ve SCCM altyapınızı kullanarak ek maliyeti sıfıra indirir ve nokta atışı kurumsal kural takibi sağlar.
[EN] Enterprise SIEM solutions are charged based on log ingestion volume. This framework utilizes your existing Microsoft 365 and SCCM infrastructure, reducing additional costs to zero while ensuring precise event monitoring.
