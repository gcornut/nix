{...}: {
  launchd.user.agents.keyboard-monitor = {
    script = ''${./usb-monitor.swift} --productId 50501 --on-connect "echo 'Keyboard connected'" --on-disconnect "echo 'Keyboard disconnected'"'';

        serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        ProcessType = "Background";
        StandardOutPath = "/var/tmp/keyboard-monitor.log";
        StandardErrorPath = "/var/tmp/keyboard-monitor.log";
      };
  };
}
