using System;
using System.IO;
using System.Linq;
using System.Reflection;
using DbUp;
using DbUp.Helpers;

namespace RandomQuotes.DbUp
{
    class Program
    {
        static int Main(string[] args)
        {
            var connectionString = args.First(x => x.StartsWith("--ConnectionString", StringComparison.OrdinalIgnoreCase));

            connectionString = connectionString.Substring(connectionString.IndexOf("=", StringComparison.InvariantCultureIgnoreCase) + 1).Replace(@"""", string.Empty);

            // retry three times
            while (true)
            {
                try
                {
                    EnsureDatabase.For.SqlDatabase(connectionString);
                    break;
                }
                catch (SqlException)
                {
                    if (retryCount < 3)
                    {
                        Console.WriteLine("Connection error occured, waiting 3 seconds then trying again.");
                        Thread.Sleep(3000);
                        retryCount += 1;
                    }
                    else
                    {
                        throw;
                    }
                }
            }

            var upgrader =
                DeployChanges.To
                    .SqlDatabase(connectionString)
                    .WithScriptsEmbeddedInAssembly(Assembly.GetExecutingAssembly())
                    .LogToConsole()
                    .Build();

            Console.WriteLine($"Is upgrade required: {upgrader.IsUpgradeRequired()}");

            if (args.Any(a => a.StartsWith("--PreviewReportPath", StringComparison.InvariantCultureIgnoreCase)))
            {
                var report = args.First(x => x.StartsWith("--PreviewReportPath", StringComparison.OrdinalIgnoreCase));
                report = report.Substring(report.IndexOf("=", StringComparison.InvariantCultureIgnoreCase) + 1).Replace(@"""", string.Empty);

                var fullReportPath = Path.Combine(report, "UpgradeReport.html");

                Console.WriteLine($"Generating the report at {fullReportPath}");

                upgrader.GenerateUpgradeHtmlReport(fullReportPath);
            }
            else
            {
                var result = upgrader.PerformUpgrade();

                if (!result.Successful)
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine(result.Error);
                    Console.ResetColor();

                    return -1;
                }

                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine("Success!");
                Console.ResetColor();
            }

            return 0;
        }
    }
}
