FROM nginx:alpine

# Copy custom nginx configuration if needed
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static content
COPY html /usr/share/nginx/html

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
