# Utilitza una imatge base d'Ubuntu
FROM ubuntu:24.04

# Actualitza els paquets i instal·la les dependències
RUN apt-get update && apt-get install -y \
	xfce4 \
	xfce4-goodies \
	tightvncserver \
	python3 \
	python3-pip \
	python3-venv \
	wget \
	openssh-server \
	sudo \
	postgresql-client

# Instal·la Flask
RUN pip3 install flask

# Descarrega i instal·la Visual Studio Code
RUN wget -qO- https://update.code.visualstudio.com/latest/linux-deb-x64/stable | apt-get install -y -

# Crea un usuari no root
RUN useradd -m developer && echo "developer:password" | chpasswd && adduser developer sudo

# Configura el servidor SSH
RUN mkdir /var/run/sshd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
EXPOSE 22

# Configura el servidor VNC
RUN mkdir -p /home/developer/.vnc
RUN echo "password" | vncpasswd -f > /home/developer/.vnc/passwd
RUN chown -R developer:developer /home/developer/.vnc
RUN chmod 600 /home/developer/.vnc/passwd
EXPOSE 5901

# Comanda per iniciar el servidor VNC i el servidor SSH
CMD su - developer -c "vncserver :1 -geometry 1280x800 -depth 24 && code" && service ssh start && tail -f /dev/null
