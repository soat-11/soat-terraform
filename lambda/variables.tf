variable "project" {
  description = "Prefixo do projeto para nomear recursos"
  type        = string
}

variable "lambda_package" {
  description = "Caminho para o arquivo ZIP do Lambda (gerado via build)"
  type        = string
}