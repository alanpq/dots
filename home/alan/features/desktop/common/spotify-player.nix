{pkgs, ...}: {
  home.packages = with pkgs; [spotify-player];
  xdg.configFile."spotify-player/app.toml" = {
    enable = true;
    text = /* toml */''
      theme = "dracula"
      client_id = "1a75d3dd8746403eb4bfe24a3b946d29"
      client_port = 8080
      playback_format = """
      {status} {track} • {artists}
      {album}
      {metadata}"""
      notify_timeout_in_secs = 0
      tracks_playback_limit = 50
      app_refresh_duration_in_ms = 32
      playback_refresh_duration_in_ms = 0
      page_size_in_rows = 20
      play_icon = "▶"
      pause_icon = "▌▌"
      liked_icon = "♥"
      border_type = "Plain"
      progress_bar_type = "Rectangle"
      playback_window_position = "Top"
      cover_img_length = 9
      cover_img_width = 5
      cover_img_scale = 1.0
      playback_window_width = 6
      enable_media_control = true
      enable_streaming = "Always"
      enable_notify = true
      enable_cover_image_cache = true
      default_device = "spotify-player"
      notify_streaming_only = false
      seek_duration_secs = 5

      [notify_format]
      summary = "{track} • {artists}"
      body = "{album}"

      [device]
      name = "spotify-player"
      device_type = "speaker"
      volume = 70
      bitrate = 320
      audio_cache = false
      normalization = false
      autoplay = true
    '';
  };
}
