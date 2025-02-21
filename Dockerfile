# Use a smaller Miniconda3 image
FROM continuumio/miniconda3:4.8.2 as builder

# Set the working directory
WORKDIR /app

# Copy the environment file
COPY environment.yml .

# Install dependencies
RUN conda env create -f environment.yml && conda clean -afy && \
    rm -rf /opt/conda/pkgs

# Copy the app files
COPY app.py .

# Create a new stage with a smaller base image
FROM debian:buster-slim

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the environment from the builder stage
COPY --from=builder /opt/conda /opt/conda

# Copy the app files
COPY --from=builder /app /app

# Set environment variables for conda
ENV PATH=/opt/conda/bin:$PATH

# Expose port 5000
EXPOSE 5000

# Run the Flask app
CMD ["conda", "run", "--no-capture-output", "-n", "flask-playground", "python", "app.py"]