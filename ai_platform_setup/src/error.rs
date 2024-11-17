use std::fmt;
use std::error::Error;

/// Custom Error type for AI Platform
#[derive(Debug)]
pub enum AiPlatformError {
    IoError(std::io::Error),
    KubernetesError(String),
    VaultError(String),
    UnknownError(String),
}

impl fmt::Display for AiPlatformError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            AiPlatformError::IoError(e) => write!(f, "IO Error: {}", e),
            AiPlatformError::KubernetesError(e) => write!(f, "Kubernetes Error: {}", e),
            AiPlatformError::VaultError(e) => write!(f, "Vault Error: {}", e),
            AiPlatformError::UnknownError(e) => write!(f, "Unknown Error: {}", e),
        }
    }
}

impl Error for AiPlatformError {}

impl From<std::io::Error> for AiPlatformError {
    fn from(error: std::io::Error) -> Self {
        AiPlatformError::IoError(error)
    }
} 