{ buildGoModule ? (import <nixpkgs> { }).buildGoModule }:
buildGoModule {
  pname = "shell-prompt";
  version = "1.0";
  vendorSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";
  src = ./.;
}
