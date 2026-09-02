{
  flake.modules.nixos.pipewire-virtual-outputs = let
    physicalOutput = "alsa_output.usb-BurrBrown_from_Texas_Instruments_USB_AUDIO_CODEC-00.analog-stereo";
  in {
    services.pipewire = {
      extraConfig.pipewire."93-virtual-sinks" = {
        "context.modules" = [
          {
            name = "libpipewire-module-loopback";
            args = {
              "node.description" = "Music";

              "capture.props" = {
                "node.name" = "music_output";
                "node.description" = "Music";
                "media.class" = "Audio/Sink";
                "audio.position" = ["FL" "FR"];
              };

              "playback.props" = {
                "node.name" = "music_output_playback";
                "audio.position" = ["FL" "FR"];

                # Replace this with your actual physical sink.
                "target.object" = physicalOutput;

                "node.passive" = true;
                "node.dont-reconnect" = true;
                "stream.dont-remix" = true;
              };
            };
          }

          {
            name = "libpipewire-module-loopback";
            args = {
              "node.description" = "Chat";

              "capture.props" = {
                "node.name" = "chat_output";
                "node.description" = "Chat";
                "media.class" = "Audio/Sink";
                "audio.position" = ["FL" "FR"];
              };

              "playback.props" = {
                "node.name" = "chat_output_playback";
                "audio.position" = ["FL" "FR"];

                "target.object" = physicalOutput;

                "node.passive" = true;
                "node.dont-reconnect" = true;
                "stream.dont-remix" = true;
              };
            };
          }

          {
            name = "libpipewire-module-loopback";
            args = {
              "node.description" = "Default";

              "capture.props" = {
                "node.name" = "default_output";
                "node.description" = "Default";
                "media.class" = "Audio/Sink";
                "audio.position" = ["FL" "FR"];
              };

              "playback.props" = {
                "node.name" = "default_output_playback";
                "audio.position" = ["FL" "FR"];

                "target.object" = physicalOutput;

                "node.passive" = true;
                "node.dont-reconnect" = true;
                "stream.dont-remix" = true;
              };
            };
          }
        ];
      };

      wireplumber.extraConfig."93-application-routing" = {
        "stream.rules" = [
          {
            matches = [
              {
                application.process.binary = "spotifyd";
              }
            ];
            actions = {
              "update-props" = {
                "target.object" = "music_output";
              };
            };
          }

          {
            matches = [
              {
                "application.name" = "discord";
                "media.class" = "Stream/Output/Audio";
              }
              {
                "application.name" = "vesktop";
                "media.class" = "Stream/Output/Audio";
              }
            ];
            actions = {
              "update-props" = {
                "target.object" = "chat_output";
              };
            };
          }
        ];
      };
    };
  };
}
