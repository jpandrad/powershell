#!/bin/bash
# Verifica se o AWS CLI está instalado
if ! command -v aws &> /dev/null
then
    # Funcao para validar erros
    check_error() {
            if [ $? -ne 0 ]; then
                    echo "Erro $1"
            fi
    }

    echo "Download do arquivo awscliv2"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    check_error "Erro ao efetuar o download do arquivo."

    echo "Descompactando o arquivo /awscliv2.zip..."
    unzip /tmp/awscliv2.zip -d /tmp/
    check_error "Erro ao descompactar o arquivo."

    echo "Instalando AWS CLI..."
    sudo /tmp/aws/install
    check_error "Erro ao instalar o AWS CLI"

    echo "Removendo o arquivo e diretorio de instalacao..."
    rm -Rf /tmp/awscliv2.zip
    check_error "Erro ao instalar o AWS CLI"
else
    echo "AWS CLI já está instalado."
    exit 0
fi