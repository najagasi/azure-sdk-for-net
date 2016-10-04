// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for
// license information.
// 
// Code generated by Microsoft (R) AutoRest Code Generator 0.16.0.0
// Changes may cause incorrect behavior and will be lost if the code is
// regenerated.

namespace Microsoft.Azure.Management.Network.Models
{
    using System;
    using System.Linq;
    using System.Collections.Generic;
    using Newtonsoft.Json;
    using Microsoft.Rest;
    using Microsoft.Rest.Serialization;
    using Microsoft.Rest.Azure;

    /// <summary>
    /// List of backendhealth pools.
    /// </summary>
    public partial class ApplicationGatewayBackendHealth
    {
        /// <summary>
        /// Initializes a new instance of the ApplicationGatewayBackendHealth
        /// class.
        /// </summary>
        public ApplicationGatewayBackendHealth() { }

        /// <summary>
        /// Initializes a new instance of the ApplicationGatewayBackendHealth
        /// class.
        /// </summary>
        public ApplicationGatewayBackendHealth(IList<ApplicationGatewayBackendHealthPool> backendAddressPools = default(IList<ApplicationGatewayBackendHealthPool>))
        {
            BackendAddressPools = backendAddressPools;
        }

        /// <summary>
        /// </summary>
        [JsonProperty(PropertyName = "backendAddressPools")]
        public IList<ApplicationGatewayBackendHealthPool> BackendAddressPools { get; set; }

    }
}
