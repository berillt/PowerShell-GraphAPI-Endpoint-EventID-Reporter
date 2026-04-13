# Enterprise Endpoint Event Reporter | Kurumsal Endpoint Olay Raporlayıcı



[TR] Bu proje, kurumsal ağdaki cihazlardan gelen karmaşık olay loglarını toplar, kritik hataları analiz eder ve Microsoft Graph API kullanarak yönetici ekibine temiz, anlamlandırılmış bir özet rapor sunar.

[EN] This project collects complex event logs from corporate devices, analyzes critical errors, and delivers a clean, meaningful summary report to the IT administration using Microsoft Graph API.



## Neden Bu Proje? | Why This Project?

Sıfır Maliyet (Zero Cost): Azure Sentinel veya Log Analytics gibi ücretli servisler yerine mevcut Microsoft 365 lisanslarını kullanır. / Utilizes existing Microsoft 365 licenses instead of paid services like Azure Sentinel or Log Analytics.

Gürültü Kirliliği Yok (Noise Reduction): Binlerce satır yerine sadece kritik ID'leri gruplayarak raporlar. / Instead of thousands of lines, it groups and reports only critical IDs.

Tam Otomatik (Fully Automated): Manuel hiçbir müdahale gerektirmez. / Requires no manual intervention.

<img width="1365" height="784" alt="Akis1" src="https://github.com/user-attachments/assets/306d23d1-82f8-4ac8-a4ff-0d5d4600b68a" />






## Teknik Gereksinimler & Kurulum | Technical Prerequisites & Setup

Bu proje üç ana bileşenin eşzamanlı çalışmasıyla kurgulanmıştır:

This project is built on the simultaneous operation of three main components:

### 1. Azure App Registration (Microsoft Graph API)
   
Mail gönderimi için Azure üzerinde bir uygulama kaydı oluşturulmalı ve şu yetkiler tanımlanmalıdır:

An application registration must be created on Azure for email delivery with the following permissions:

API / Permission Name: Mail.Send

Type: Application (Send mail as any user)

Admin Consent: Gerekli / Required

<img width="1368" height="768" alt="API_permissions" src="https://github.com/user-attachments/assets/76e6bd28-4036-4ad5-aa4e-191f67b32fe2" />



### 2. Ağ Paylaşımı & Klasör Yetkileri | Shared Folder & Permissions
   
İstemci tarafındaki scriptin verileri bırakabilmesi için bir dosya sunucusu alanı gereklidir:

A file server area is required for the client-side script to drop data:

Shared Folder Path: \\<YOUR_SERVER_NAME>\<YOUR_SHARE_NAME>$

Share Permissions: Everyone veya Domain Computers için Full Control.

Security (NTFS) Permissions: Domain Computers grubu için Modify, Read & Execute, List folder contents, Read, Write yetkileri tanımlanmalıdır.

<img width="955" height="1120" alt="shared_folder" src="https://github.com/user-attachments/assets/c6b6da30-0686-487f-b935-b8239b67cf26" />



### 3. Görev Zamanlayıcı Yapılandırması | Task Scheduler Configuration
   
Raporun otomatize edilmesi için merkezi sunucuda bir görev tanımlanmalıdır:

A scheduled task must be defined on the central server to automate the report:


Trigger (Tetikleyici): Daily (Günlük), Belirlenen saatte (Örn: 18:00).

Action (Eylem): Start a program

Program/script: powershell.exe

Add arguments: -ExecutionPolicy Bypass -File "C:\<PATH_TO_SCRIPT>\Central-Server-Script.ps1"

Start in: C:\<WORKING_DIRECTORY>

<img width="1078" height="976" alt="task_scheduler" src="https://github.com/user-attachments/assets/fb70df54-73ba-4ce8-b982-4608412fd52d" />




### 4. Intune Remediation Yapılandırması | Intune Remediation Configuration

<img width="1234" height="848" alt="ıNTUNE" src="https://github.com/user-attachments/assets/d0179682-aaae-44c7-bcd6-446dddb84b5b" />


Yapılandırma Detayları / Configuration Details:

Detection Script: Intune'un her zaman düzeltme (remediation) aşamasına geçmesini sağlayan exit 1 mantığını içerir.

Remediation Script: Logları süzen ve ağ paylaşımına (\\<SERVER_IP>\Share$) gönderen ana scripttir.

Run credentials: No (SYSTEM yetkisi için).

64-bit PowerShell: Yes.



### Örnek Rapor Çıktısı | Sample Report Output

Sistem başarıyla çalıştığında, yöneticilere ulaşan mail ve ekindeki analiz raporu şu şekilde görünmektedir:

Mail Özeti / Email Summary:

Konu / Subject: Client Device Critical Event Report - 1

Kimden / From: <REPORTS_SENDER_MAIL> (Örn: reports@isuzu.com.tr)

Kime / To: <RECIPIENT_1>; <RECIPIENT_2>; <RECIPIENT_3>

Gönderi İçeriği / Body:

Plaintext

Device-based critical event analysis report is attached.

Total Device Count: 2

Ek / Attachment: Generic_Event_Analysis.zip [512 bytes]

ZIP İçeriği (CSV) / ZIP Content (CSV):

Görselin Sağ Tarafı / Right Side of Image: MergedEvents.csv dosyası, toplanan logların anlamlandırılmış halini gösterir.

Alanlar / Fields:

Device Name: <DEVICE_A> (Örn: ISU00660)

Event IDs: 7, 11, 51, 18, 4101

Critical Descriptions: 7: Disk Error (Bad Block) | 11: Controller Error

<img width="1365" height="784" alt="LAST_RREPOR" src="https://github.com/user-attachments/assets/e978263a-dece-4973-aef8-35cea855da0f" />

### SIEM vs. This Solution

Kurumsal SIEM çözümleri (Sentinel/Splunk vb.) log hacmine göre ücretlendirilir. Bu çözüm ise tamamen mevcut altyapıyı kullanarak ek maliyeti sıfıra indirir.

Enterprise SIEM solutions are charged by log volume. This solution reduces additional costs to zero by using the existing infrastructure.
