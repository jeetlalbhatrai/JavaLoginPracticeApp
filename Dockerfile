# ---------- Stage 1: Build WAR using Maven ----------
FROM maven:3.9.9-eclipse-temurin-17 AS builder

# Set working directory
WORKDIR /app

# Copy pom.xml first (better caching)
COPY pom.xml .

# Download dependencies (cached layer)
RUN mvn dependency:go-offline

# Copy source code
COPY src ./src

# Build the WAR file
RUN mvn clean package -DskipTests


# ---------- Stage 2: Deploy on Tomcat ----------
FROM tomcat:10.1-jdk17-temurin

# Remove default ROOT app (optional but cleaner)
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR from builder stage
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/JavaLoginShowcase.war

# Expose Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
