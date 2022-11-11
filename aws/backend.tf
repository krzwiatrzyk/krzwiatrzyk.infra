terraform {
  cloud {
    organization = "krzwiatrzyk"

    workspaces {
      name = "windkube"
      # tags = ["networking", "source:cli"]
    }
  }
}