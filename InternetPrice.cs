using System;
using System.Collections.Generic;
using System.Net;

namespace Webby
{
    class Program
    {
        public static void Main(string[] args)
        {
			var epoch = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
			DateTime now=DateTime.Today,now2=now.AddDays(-30);
			if(args.Length>=2){
				int back = Int32.Parse(args[1]);
				now2=now.AddDays(-back);
			}
			double p1=(now2.ToUniversalTime() - epoch).TotalSeconds;
			double p2=(now.ToUniversalTime() - epoch).TotalSeconds;
            string csvData=null,crumb="DJCSezeQxOX",cookie="B=fn7mr5dd0thub&b=3&s=77",stockID="ANTO.L";
			if(args.Length>=1)stockID=args[0];
            using (WebClient web = new WebClient())
            {
              /*Get crumb and cookie: Lasts for a year. (I got it on 17-11-2017)
               * cookie is in the header from wget (hence -S option)
               * 
               * wget -S https://uk.finance.yahoo.com/quote/ANTO.L/history
               * awk -F, '/CrumbStore/{for(i=1;i<NF;++i){print $i}}' history|sed -n "/Crumb/p"
               *
               *  */
              web.Headers.Add(HttpRequestHeader.Cookie,cookie);
              //l1 for last price, p for previous close price. (Same at weekend)
				while(csvData==null)
				{
					try {
						csvData = web.DownloadString(string.Format("https://query1.finance.yahoo.com/v7/finance/download/{0}?events=history&interval=1d&crumb={1}&period1={2}&period2={3}",stockID,crumb,p1,p2));
					}catch{
						break;
					}
				}
			}
			if(csvData!=null)Console.WriteLine(string.Format(csvData));
		}
	}
}
