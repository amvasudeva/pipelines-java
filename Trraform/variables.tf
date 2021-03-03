# Define prefix for consistent resource naming.
variable "resource_prefix" {
    type        = string
    default     = "Tst-demo"
    description = "Service prefix to use for naming of resources."
}

# Define Azure region for resource placement.
variable "location" {
    type        = string
    default     = "eastus"
    description = "Azure region for deployment of resources."
}