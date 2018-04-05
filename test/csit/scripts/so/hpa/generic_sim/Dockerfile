# Use an official Python runtime as a parent image
FROM python:2.7

# Set the working directory to /su/python/webpy-rest-dockerized
WORKDIR /opt/generic_sim

# Copy the current directory contents into the container at /app
ADD ./  /opt/generic_sim

# Install any needed packages specified in requirements.txt
RUN pip install web.py

# Make port 80 available to the world outside this container
EXPOSE 8081

# Define environment variable
ENV NAME generic_sim

# Run generic_sim.py when the container launches
CMD ["/bin/sh", "-c", "python -u generic_sim.py 8081 > /generic_sim_logs/generic_sim.log 2>&1"]