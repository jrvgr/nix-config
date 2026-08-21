{...}: {
  programs.lazygit = {
    enable = true;
    settings = {
      services = {
        github_work = "github:github.com";
        github_personal = "github:github.com";
      };
    };
  };
}
