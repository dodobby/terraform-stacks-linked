#!/bin/bash
yum update -y
yum install -y httpd

# 간단한 웹 페이지 생성
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>HJDO Application - ${environment}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background-color: #232f3e; color: white; padding: 20px; }
        .content { padding: 20px; }
        .environment { color: #ff9900; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <h1>HJDO Application</h1>
        <p>Environment: <span class="environment">${environment}</span></p>
    </div>
    <div class="content">
        <h2>Welcome to HJDO Application</h2>
        <p>This is a sample application running on AWS.</p>
        <p>Instance ID: <span id="instance-id">Loading...</span></p>
        <p>Availability Zone: <span id="az">Loading...</span></p>
    </div>
    
    <script>
        // Instance metadata 가져오기
        fetch('http://169.254.169.254/latest/meta-data/instance-id')
            .then(response => response.text())
            .then(data => document.getElementById('instance-id').textContent = data)
            .catch(error => document.getElementById('instance-id').textContent = 'N/A');
            
        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone')
            .then(response => response.text())
            .then(data => document.getElementById('az').textContent = data)
            .catch(error => document.getElementById('az').textContent = 'N/A');
    </script>
</body>
</html>
EOF

# Apache 시작 및 부팅 시 자동 시작 설정
systemctl start httpd
systemctl enable httpd

# CloudWatch 에이전트 설치 (선택사항)
yum install -y amazon-cloudwatch-agent