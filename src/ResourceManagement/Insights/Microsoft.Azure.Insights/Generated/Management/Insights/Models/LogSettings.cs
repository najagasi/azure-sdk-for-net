// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for
// license information.
// 
// Code generated by Microsoft (R) AutoRest Code Generator 0.17.0.0
// Changes may cause incorrect behavior and will be lost if the code is
// regenerated.

namespace Microsoft.Azure.Management.Insights.Models
{
    using System.Linq;

    /// <summary>
    /// Part of MultiTenantDiagnosticSettings. Specifies the settings for a
    /// particular log.
    /// </summary>
    public partial class LogSettings
    {
        /// <summary>
        /// Initializes a new instance of the LogSettings class.
        /// </summary>
        public LogSettings() { }

        /// <summary>
        /// Initializes a new instance of the LogSettings class.
        /// </summary>
        /// <param name="enabled">a value indicating whether this log is
        /// enabled.</param>
        /// <param name="category">the name of the logs to which this setting
        /// is applied.</param>
        /// <param name="retentionPolicy">the retention policy for this
        /// log.</param>
        public LogSettings(bool enabled, string category = default(string), RetentionPolicy retentionPolicy = default(RetentionPolicy))
        {
            Category = category;
            Enabled = enabled;
            RetentionPolicy = retentionPolicy;
        }

        /// <summary>
        /// Gets or sets the name of the logs to which this setting is applied.
        /// </summary>
        [Newtonsoft.Json.JsonProperty(PropertyName = "category")]
        public string Category { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this log is enabled.
        /// </summary>
        [Newtonsoft.Json.JsonProperty(PropertyName = "enabled")]
        public bool Enabled { get; set; }

        /// <summary>
        /// Gets or sets the retention policy for this log.
        /// </summary>
        [Newtonsoft.Json.JsonProperty(PropertyName = "retentionPolicy")]
        public RetentionPolicy RetentionPolicy { get; set; }

        /// <summary>
        /// Validate the object.
        /// </summary>
        /// <exception cref="Microsoft.Rest.ValidationException">
        /// Thrown if validation fails
        /// </exception>
        public virtual void Validate()
        {
            if (this.RetentionPolicy != null)
            {
                this.RetentionPolicy.Validate();
            }
        }
    }
}
