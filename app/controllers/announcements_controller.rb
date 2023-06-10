# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  before_action :set_announcement, only: %i[show edit update destroy]
  before_action :rewrite_announcement, only: %i[update]

  def index; end

  def show; end

  def new
    @announcement = Announcement.new(target: 'students')

    if params[:id]
      announcement = Announcement.find(params[:id])
      @announcement.title       = announcement.title
      @announcement.description = announcement.description
      @announcement.target = announcement.target
      flash.now[:notice] = 'お知らせをコピーしました。'
    elsif params[:page_id]
      page = Page.find(params[:page_id])
      template = MessageTemplate.load('page_announcements.yml', hash: { page: page })
      @announcement.title       = template['title']
      @announcement.description = template['description']
    elsif params[:event_id]
      event = Event.find(params[:event_id])
      template = MessageTemplate.load('event_announcements.yml', hash: { event: event })
      @announcement.title       = template['title']
      @announcement.description = template['description']
    end
  end

  def edit; end

  def update
    set_wip

    if @announcement.update(announcement_params)
      Newspaper.publish(:announcement_update, @announcement)
      redirect_to @announcement, notice: notice_message(@announcement)
    else
      render :edit
    end
  end

  def create
    @announcement = Announcement.new(announcement_params)
    @announcement.user_id = current_user.id
    set_wip
    if @announcement.save
      Newspaper.publish(:announcement_create, @announcement)
      redirect_to @announcement, notice: notice_message(@announcement)
    else
      render :new
    end
  end

  def destroy
    @announcement.destroy
    Newspaper.publish(:announcement_destroy, @announcement)
    redirect_to announcements_path, notice: 'お知らせを削除しました'
  end

  private

  def announcement_params
    params.require(:announcement).permit(:title, :description, :target)
  end

  def set_announcement
    @announcement = Announcement.find(params[:id])
  end

  def set_wip
    @announcement.wip = (params[:commit] == 'WIP')
  end

  def notice_message(announcement)
    case params[:action]
    when 'create'
      announcement.wip? ? 'お知らせをWIPとして保存しました。' : 'お知らせを作成しました。'
    when 'update'
      announcement.wip? ? 'お知らせをWIPとして保存しました。' : 'お知らせを更新しました。'
    end
  end

  def rewrite_announcement
    return unless conflict?

    set_entered_announcement

    flash.now[:alert] = '別の人がお知らせを更新していたので更新できませんでした。'
    render :edit
  end

  def conflict?
    Time.zone.parse(params['announcement']['updated_at']).utc.floor != Announcement.find(params[:id]).updated_at.utc.floor
  end

  def set_entered_announcement
    @announcement.assign_attributes(updated_at: params['announcement']['updated_at'], \
                                    title: params['announcement']['title'], \
                                    description: params['announcement']['description'], \
                                    target: params['announcement']['target'])
  end
end
