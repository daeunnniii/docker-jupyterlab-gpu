# jupyterlab-gpu
Configuring a jupyterlab Environment Using Nvidia GPU

### 환경변수 설정
도커 이미지 빌드 및 실행을 위한 환경변수를 .env 파일에서 설정
```plaintext
USERNAME=<username>
JUPYTER_PORT=<port>
JUPYTER_PASSWORD=<passowrd>
...
```

### 패키지 추가
JupyterLab 환경에 필요한 Python 패키지 및 의존성 추가

#### 1. requirements-conda.yml
```yaml
name: base
channels:
  - anaconda
  - conda-forge
dependencies:
  - numpy
  - pandas
```

#### 2. requirements-pip.txt
```plaintext
matplotlib
seaborn
scikit-learn
opencv-python
```

### 실행
```bash
~$ git clone https://github.com/daeunnniii/jupyterlab-gpu.git
~$ docker compose up tf2.17-torch2.5 -d
```
