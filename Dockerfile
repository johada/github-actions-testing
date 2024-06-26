# Use the Nginx base image
FROM nginx

# Set an ARG (argument) with a default value
ARG MY_VARIABLE="Descripción para el proyecto"

# Print the variable during the build process
RUN echo "My variable: ${MY_VARIABLE}"

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf