// Copyright 2012 Henrik Feldt

using System;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using NLog;
using System.Linq;

namespace insert_data
{
	internal class Program
	{
		// will feed some message lines to the 
		static void Main()
		{
			var logger = LogManager.GetCurrentClassLogger();
			var now = DateTime.UtcNow;
			var from = now.Subtract(TimeSpan.FromMinutes(15));

			GenerateData(logger, now, @from);
		}

		static void GenerateData(Logger logger, DateTime init, DateTime @from)
		{
			var rand = new Random();
			var levels = new[] { LogLevel.Trace, LogLevel.Debug, LogLevel.Info, LogLevel.Warn };
			var messages = File.ReadAllLines("messages.txt");
			var tags = File.ReadAllText("tags.txt").Split(' ').Select(t => t.Trim(new[] { '.' })).ToArray();

			Console.WriteLine("Starting live data generation.");

			while (true)
			{
				logger.Log(levels[rand.Next(levels.Length)],
					messages[rand.Next(messages.Length)],
					tags: new[] { tags[rand.Next(tags.Length)] },
					fields: new Dictionary<string, object>
						{
							{ "curr-position", DateTime.UtcNow - init }
						});

				Thread.Sleep(20);
			}
		}
	}
}