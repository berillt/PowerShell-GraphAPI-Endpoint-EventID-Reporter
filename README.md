Enterprise Endpoint Event Reporter | Kurumsal Endpoint Olay Raporlayıcı
Bu proje, kurumsal ağdaki cihazlardan gelen karmaşık olay loglarını toplar, kritik hataları analiz eder ve Microsoft Graph API kullanarak yönetici ekibine temiz, anlamlandırılmış bir özet rapor sunar.
This project collects complex event logs from corporate devices, analyzes critical errors, and delivers a clean, meaningful summary report to the IT administration using Microsoft Graph API.

Neden Bu Proje? | Why This Project?
Sıfır Maliyet (Zero Cost): Azure Sentinel veya Log Analytics gibi ücretli servisler yerine mevcut Microsoft 365 lisanslarını kullanır. / Utilizes existing Microsoft 365 licenses instead of paid services like Azure Sentinel or Log Analytics.

Gürültü Kirliliği Yok (Noise Reduction): Binlerce satır yerine sadece kritik ID'leri gruplayarak raporlar. / Instead of thousands of lines, it groups and reports only critical IDs.

Tam Otomatik (Fully Automated): Manuel hiçbir müdahale gerektirmez. / Requires no manual intervention.




Teknik Gereksinimler & Kurulum | Technical Prerequisites & Setup
Bu proje üç ana bileşenin eşzamanlı çalışmasıyla kurgulanmıştır:
This project is built on the simultaneous operation of three main components:

1. Azure App Registration (Microsoft Graph API)
Mail gönderimi için Azure üzerinde bir uygulama kaydı oluşturulmalı ve şu yetkiler tanımlanmalıdır:
An application registration must be created on Azure for email delivery with the following permissions:

API / Permission Name: Mail.Send

Type: Application (Send mail as any user)

Admin Consent: Gerekli / Required


2. Ağ Paylaşımı & Klasör Yetkileri | Shared Folder & Permissions
İstemci tarafındaki scriptin verileri bırakabilmesi için bir dosya sunucusu alanı gereklidir:
A file server area is required for the client-side script to drop data:

Shared Folder Path: \\<YOUR_SERVER_NAME>\<YOUR_SHARE_NAME>$

Share Permissions: Everyone veya Domain Computers için Full Control.

Security (NTFS) Permissions: Domain Computers grubu için Modify, Read & Execute, List folder contents, Read, Write yetkileri tanımlanmalıdır.


3. Görev Zamanlayıcı Yapılandırması | Task Scheduler Configuration
Raporun otomatize edilmesi için merkezi sunucuda bir görev tanımlanmalıdır:
A scheduled task must be defined on the central server to automate the report:

Trigger (Tetikleyici): Daily (Günlük), Belirlenen saatte (Örn: 18:00).

Action (Eylem): Start a program

Program/script: powershell.exe

Add arguments: -ExecutionPolicy Bypass -File "C:\<PATH_TO_SCRIPT>\Central-Server-Script.ps1"

Start in: C:\<WORKING_DIRECTORY>

💰 SIEM vs. This Solution
Kurumsal SIEM çözümleri (Sentinel/Splunk vb.) log hacmine göre ücretlendirilir. Bu çözüm ise tamamen mevcut altyapıyı kullanarak ek maliyeti sıfıra indirir.
Enterprise SIEM solutions are charged by log volume. This solution reduces additional costs to zero by using the existing infrastructure.
