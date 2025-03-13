# Use OpenJDK 8 for compatibility with the build
FROM openjdk:8-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy necessary files, including settings.gradle from desktop_app folder
COPY gradlew ./
COPY gradle /app/gradle
COPY build.gradle /app/build.gradle
COPY desktop_app/settings.gradle /app/settings.gradle

# Make Gradle wrapper executable
RUN chmod +x gradlew

# Install Python and dependencies for Selenium testing
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    unzip

# Install pipenv for managing Python dependencies
RUN pip3 install pipenv

# Display Java and Gradle versions at container startup (for debugging)
RUN java -version
RUN ./gradlew -v

# Install Chromedriver
RUN curl -sSL https://chromedriver.storage.googleapis.com/113.0.5672.63/chromedriver_linux64.zip -o chromedriver.zip \
    && unzip chromedriver.zip \
    && mv chromedriver /usr/local/bin/ \
    && rm chromedriver.zip

# Install required Python dependencies using pipenv
COPY Pipfile* ./
RUN pipenv install

# Expose the application's port (default is 8080 for this demo)
EXPOSE 8080

# Command to run the application
CMD ["./gradlew", "apprun"]


# Add a health check to verify that the app is running
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl --fail http://localhost:8080 || exit 1