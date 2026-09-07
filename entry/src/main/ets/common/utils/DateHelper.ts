export class DateHelper {
  static getCurrentDateString(): string {
    return DateHelper.formatDateKey(new Date());
  }

  static formatDateKey(date: Date): string {
    const year = date.getFullYear();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return `${year}-${month}-${day}`;
  }

  static formatDisplayDate(date: Date): string {
    const month = date.getMonth() + 1;
    const day = date.getDate();

    const today = new Date();
    const todayKey = DateHelper.formatDateKey(today);
    const dateKey = DateHelper.formatDateKey(date);

    const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
    const yesterdayKey = DateHelper.formatDateKey(yesterday);

    const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000);
    const tomorrowKey = DateHelper.formatDateKey(tomorrow);

    let suffix = '';
    if (dateKey === todayKey) {
      suffix = '今天';
    } else if (dateKey === yesterdayKey) {
      suffix = '昨天';
    } else if (dateKey === tomorrowKey) {
      suffix = '明天';
    } else {
      const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
      suffix = weekdays[date.getDay()];
    }

    return `${month}月${day}日 ${suffix}`;
  }

  static addDays(date: Date, days: number): Date {
    const newDate = new Date(date.getTime());
    newDate.setDate(newDate.getDate() + days);
    return newDate;
  }

  static getWeekDates(refDate: Date = new Date()): WeekDayInfo[] {
    const jsDay = refDate.getDay();
    const monOffset = jsDay === 0 ? -6 : 1 - jsDay;
    const monday = new Date(refDate.getFullYear(), refDate.getMonth(), refDate.getDate() + monOffset);
    const dayLabels = ['一', '二', '三', '四', '五', '六', '日'];
    const result: WeekDayInfo[] = [];

    for (let i = 0; i < 7; i++) {
      const d = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + i);
      result.push({
        date: d,
        dateKey: DateHelper.formatDateKey(d),
        dayLabel: dayLabels[i]
      });
    }
    return result;
  }

  static getMonthWeeks(refDate: Date = new Date()): MonthWeekInfo[] {
    const year = refDate.getFullYear();
    const month = refDate.getMonth();
    const mStr = (month + 1).toString().padStart(2, '0');
    const lastDay = new Date(year, month + 1, 0).getDate();

    return [
      {
        weekLabel: '第1周',
        startDateKey: `${year}-${mStr}-01`,
        endDateKey: `${year}-${mStr}-07`
      },
      {
        weekLabel: '第2周',
        startDateKey: `${year}-${mStr}-08`,
        endDateKey: `${year}-${mStr}-14`
      },
      {
        weekLabel: '第3周',
        startDateKey: `${year}-${mStr}-15`,
        endDateKey: `${year}-${mStr}-21`
      },
      {
        weekLabel: '第4周',
        startDateKey: `${year}-${mStr}-22`,
        endDateKey: `${year}-${mStr}-${lastDay.toString().padStart(2, '0')}`
      }
    ];
  }
}

export interface WeekDayInfo {
  date: Date;
  dateKey: string;
  dayLabel: string;
}

export interface MonthWeekInfo {
  weekLabel: string;
  startDateKey: string;
  endDateKey: string;
}
