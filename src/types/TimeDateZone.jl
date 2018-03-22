const AkoTimeZone = Union{VariableTimeZone, FixedTimeZone}

struct TimeDateZone <: AbstractTime
    timedate::TimeDate
    in_zone::AkoTimeZone
    at_zone::FixedTimeZone
    
    function TimeDateZone(timedate::TimeDate, in_zone::VariableTimeZone, at_zone::FixedTimeZone)
        new(timedate, in_zone, at_zone)
    end
    
    function TimeDateZone(timedate::TimeDate, in_zone::FixedTimeZone, at_zone::FixedTimeZone)
        new(timedate, in_zone, at_zone)
    end

    function TimeDateZone(timedate::TimeDate, in_zone::AkoTimeZone)
        zdt = ZonedDateTime(DateTime(timedate), in_zone)
        new(timedate, zdt.timezone, zdt.zone)
    end
end

@inline timedate(x::TimeDateZone) = x.timedate
@inline at_time(x::TimeDateZone) = x.timedate.at_time
@inline on_date(x::TimeDateZone) = x.timedate.on_date
@inline nanomicro(x::TimeDateZone) = nanomicro(x.timedate)
@inline datetime(x::TimeDateZone) = datetime(x.timedate)
@inline in_zone(x::TimeDateZone) = x.in_zone
@inline at_zone(x::TimeDateZone) = x.at_zone


TimeDateZone(time::Time, date::Date, in_zone::T) where {T<:AkoTimeZone} =
    TimeDateZone(TimeDate(time,date), in_zone)
TimeDateZone(datetime::DateTime, in_zone::T) where {T<:AkoTimeZone} =
    TimeDateZone(Time(datetime), Date(datetime), in_zone)
TimeDateZone(date::Date, in_zone::T) where {T<:AkoTimeZone} =
    TimeDateZone(TIME0, date, in_zone)

function TimeDateZone(zdt::ZonedDateTime)
   datetime = DateTime(zdt)
   timedate = TimeDate(datetime)
   in_zone = zdt.timezone
   at_zone = zdt.zone
   TimeDateZone(timedate, in_zone, at_zone)
end

function ZonedDateTime(tdz::TimeDateZone)
    timedate = tdz.timedate
    datetime = DateTime(timedate)
    in_zone = tdz.in_zone
    at_zone = tdz.at_zone
    ZonedDateTime(datetime, in_zone)
end

function Base.:(+)(tdz::TimeDateZone, per::Period)
    nanosecs = nanomicro(tdz)
    zdt = ZonedDateTime(tdz)
    zdt = zdt + per
    datetime = DateTime(zdt)
    timedate = TimeDate(datetime)
    at_time, on_date = at_time(timedate), on_date(timedate)
    at_time = at_time + nanosecs
    timedate = TimeDate(at_time, on_date)
    TimeDateZone(timedate, zdt.timezone)
end
    
