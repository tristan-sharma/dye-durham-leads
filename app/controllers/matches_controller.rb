class MatchesController < ApplicationController
  before_action :authenticate_user!
  include Pagy::Backend

  def _us_week_number_for_date(date, return_week = false)
    year = date.year
    year_range = [*year - 1..year + 1]
    week_number = -1
    weeks_range = [*1..52]
    current_week_obj = nil
    year_range.each do |y|
      # Iterate over all weeks in the year to see which one includes provided date
      weeks_range.each do |week|
        # Set start day of week to sunday
        full_weeks_range = Date.commercial(y, week).all_week(:sunday).to_a
        if full_weeks_range.include? date
          week_number = week
          current_week_obj = full_weeks_range
          break
        end
      end
    end
    unless return_week
      return week_number
    end
    current_week_obj
  end

  def index
    @user_id = current_user.id
    all_matches = Match.all.order(matched_on: :asc)
    had_page_attribute_in_url = true

    begin
      page_number = Base64.decode64(params[:puid])
    rescue
      page_number = 1
      had_page_attribute_in_url = false
    end

    first_week_matched = all_matches.first
    last_week_matched = all_matches.last
    @weeks = {}
    @months = {}
    years_with_matches = [*first_week_matched.year_matched..last_week_matched.year_matched]
    @weeks_array = []
    current_month = ''

    week_page_num = 0

    wpn_count = 0

    page_nums_to_repeat = []

    current_active_week_page_number = 0

    current_page_num = 0

    years_with_matches.each_with_index do |year, index|
      weeks_for_year = [*1..52]
      is_current_year = Time.now.year == year
      is_last_year = index == years_with_matches.length - 1
      current_active_week_page_number = _us_week_number_for_date(Date.today)
      if index.zero?
        weeks_for_year = [*first_week_matched.week_matched..52]
        if is_current_year && is_last_year
          latest_week_of_year = _us_week_number_for_date(Date.today)
          weeks_for_year = [*first_week_matched.week_matched..latest_week_of_year]
        end
      else
        if is_current_year && is_last_year
          latest_week_of_year = _us_week_number_for_date(Date.today)
          last_week_matched_for_year = Match.where(year_matched: year).order(matched_on: :desc).first
          last_week_to_include = last_week_matched_for_year.week_matched > latest_week_of_year ? last_week_matched_for_year.week_matched : latest_week_of_year
          weeks_for_year = [*1..last_week_to_include]
        else
          weeks_for_year = [*1..52]
        end
      end
      if is_last_year && !is_current_year
        last_week_matched_for_year = Match.where(year_matched: year).order(matched_on: :desc).first
        weeks_for_year = [*1..last_week_matched_for_year.week_matched]
      elsif is_current_year && is_last_year
        # weeks_for_year = [*]
      end
      wpn_count += weeks_for_year.length
      insert_into_next_month = false
      insert_into_previous_month = false
      weeks_for_year.each_with_index do |week, week_index|
        processing_current_week = false
        is_last_week = week_index == weeks_for_year.length - 1
        week_page_num += 1
        month = Date.commercial(year, week).all_week(:sunday).first.strftime("%b %Y")
        last_week_of_month = false
        if current_month != month
          current_month = month
          last_week_of_month = true
        end
        date_obj = Date.commercial(year, week).all_week(:sunday).first
        y = _us_week_number_for_date(date_obj, true)
        month_number = y.first.month
        year_number = y.first.year
        if month_number != date_obj.month
          month_number = date_obj.month
          year_number = date_obj.year
        end
        unless @months["#{month_number} #{year_number}"]
          @months["#{month_number} #{year_number}"] = {
              month_name: date_obj.strftime("%B %Y"),
              weeks: []
          }
        end
        if insert_into_next_month
          @months["#{date_obj.month} #{date_obj.year}"][:weeks].push(
              **insert_into_next_month,
              page_num: week_page_num,
              real_page_num: week_page_num - 1,
              prev: week_page_num - 2,
              next: week_page_num + 1,
              double_counted: true
          )
          insert_into_next_month = false
          week_page_num += 1
        end
        if y.first.month < y.last.month || y.first.year < y.last.year
          insert_into_next_month = {
              week_obj: y,
              page_num: week_page_num,
              week_key: "#{year}-#{week}",
              week_number: week,
              next: week_page_num + 2,
              double_counted: true
          }
          page_nums_to_repeat.push("#{year}-#{week}")
          @weeks_array.push("#{year}-#{week}")
        end
        @months["#{month_number} #{year_number}"][:weeks].push(
            week_obj: y,
            page_num: week_page_num,
            week_key: "#{year}-#{week}",
            week_number: week,
            dupl_page_num: insert_into_next_month ? week_page_num + 1 : nil,
            next: insert_into_next_month ? week_page_num + 2 : week_page_num + 1,
            prev: week_page_num - 1
        )
        is_last_match_week = is_last_year && is_last_week
        @weeks["#{year}-#{week}"] = {
            year: year,
            week: week,
            month: y,
            has_matches: false,
            last_week_of_month: last_week_of_month,
            is_last_match_week: is_last_match_week,
            is_active_week: week_page_num == page_number.to_i,
            is_first_match_week: index.zero? && week_index.zero?
        }
        @weeks_array.push("#{year}-#{week}")
        if is_current_year
          if current_active_week_page_number == week
            current_page_num = week_page_num
            @months["#{date_obj.month} #{date_obj.year}"][:is_current_page] = true
          end
        end
      end
    end

    all_matches.each do |match|
      week_object = @weeks["#{match.year_matched}-#{match.week_matched}"]
      if week_object
        week_object[:has_matches] = true
      end
    end

    year_org = []

    years = Match.order("year_matched ASC").distinct.pluck(:year_matched)
    weeks_count = 0
    cur_week = 0
    years.each_with_index do |y, index|
      matches = Match.distinct.where(year_matched: y).order(:week_matched).pluck(:week_matched)

      weeks_of_matches = matches

      year_orgs = index.zero? ? Match.year_organized(y, weeks_of_matches.first) : Match.year_organized(y)

      weeks_count += year_orgs.length

      year_orgs.each do |x|
        should_be_repeated = page_nums_to_repeat.include? x[0]["key"]
        if should_be_repeated
          year_org.push(x)
          year_org.push(x)
        else
          year_org.push(x)
        end
      end



      weeks_of_matches.each do |m|
        cur_week += 1
        days_week = Date.commercial(y, m).all_week(:sunday).to_a

        current_week_number = _us_week_number_for_date(Date.commercial(y, m))

        _week_obj = @weeks["#{y}-#{m}"]

        if _week_obj[:week] == current_week_number
          _week_obj[:is_active_week] = true
        end

        arr = []
        days_week.each do |d|
          address_states = []
          if _week_obj[:is_active_week]
            match_records = Match.where(matched_on: d)
            match_records.each do |s|
              user_match_states = UserMatchState.where(user_id: @user_id, match_id: s.id).first
              dd_key = Match.where(id: s.id).pluck(:dd_key)[0]
              if user_match_states
                user_match_state = [user_match_states.status_before_type_cast, dd_key]
              else
                user_match_state = [0, dd_key]
              end
              address_states.push("#{s.address}" => user_match_state)
            end
          end

          arr.push({"date" => d, "addresses" => address_states, "key" => "#{y}-#{m}"})
        end
        _indexes = @weeks_array.map.with_index { |a, i| a == "#{y}-#{m}" ? i : nil }.compact
        _indexes.each do |i|
          year_org[i] = arr
        end
      end
    end

    # Slice
    @highest_week = week_page_num + 1
    l = wpn_count + page_nums_to_repeat.length

    @pagy, @addresses = pagy_array(year_org, items: 1, page: page_number)

    if params["cm"]
      @current_month_slide = params["cm"].to_i
    else
      @current_month_slide = -1
      current_month_slide_found = false

      month_weeks_count = 0

      @months.each do |key, month|
        unless current_month_slide_found
          @current_month_slide += 1
        end
        if month[:is_current_page]
          current_month_slide_found = true
        end
        month_weeks_count += month[:weeks].length
      end
    end

    unless had_page_attribute_in_url
      base64_page_num = Base64.strict_encode64(current_page_num.to_s)
      redirect_to puid: base64_page_num, cm: @current_month_slide
    end

  end

  def update_status
    match = Match.find_by(address: params[:address])
    user_match_state = UserMatchState.find_by(match: match.id, user: current_user.id)
    unless user_match_state
      UserMatchState.create(match: match, user: current_user)
    end
    match.user_match_states.update(status: params[:new_status])

    respond_to do |format|
      format.json {
        render json: update_status_params
      }
    end
  end

  def mark_link_viewed
    match = Match.find_by(address: params[:address])
    match_state = match.user_match_states[0]
    unless match_state
      UserMatchState.create(match: match, user: current_user)
      match.reload
      match_state = match.user_match_states[0]
    end
    status_updated = false

    if match_state.status === "unviewed"
      match.user_match_states.update(status: "viewed")
      status_updated = true
    end

    respond_to do |format|
      format.json {
        render json: {
            status_updated: status_updated
        }
      }
    end
  end

  private

  def update_status_params
    params.require([:new_status, :date, :address])
  end
end