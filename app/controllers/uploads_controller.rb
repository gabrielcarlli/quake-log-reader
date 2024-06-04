class UploadsController < ApplicationController
  def create
    if params[:log].present?
      @log = params[:log]
      if valid_log_file?(@log)
        log_path = Rails.root.join('public', 'uploads', @log.original_filename)
        File.open(Rails.root.join('public', 'uploads', @log.original_filename), 'wb') do |log|
          log.write(@log.read)
        end

        log = File.read(log_path)
        @matches = UploadsHelper.parse_log(log)

        render 'show'
      else
        redirect_to root_path, error: "Only .log logs are allowed."
      end
    else
      redirect_to root_path, alert: "Please select a log to upload."
    end
  end

  def demo
    log_path = Rails.root.join('public', 'uploads', 'qgames.log')

    log = File.read(log_path)
    @matches = UploadsHelper.parse_log(log)

    render 'show'
  end

  def valid_log_file?(log)
    log.original_filename.end_with?('.log') && ['text/plain', 'application/octet-stream'].include?(log.content_type)
  end
end
