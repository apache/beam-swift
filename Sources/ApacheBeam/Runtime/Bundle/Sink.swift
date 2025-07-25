/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 *  License); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an  AS IS BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import Foundation
import Logging

final class Sink: SerializableFn {
    let client: DataplaneClient
    let coder: Coder
    
    let log: Logger

    public init(client: DataplaneClient, coder: Coder) {
        self.client = client
        self.coder = coder
        log = Logger(label: "Sink")
    }

    func process(context: SerializableFnBundleContext,
                 inputs: [AnyPCollectionStream], outputs _: [AnyPCollectionStream]) async throws -> (String, String)
    {
        let bytesWritten = await context.metrics.counter(name: "bytes-written")
        let recordsWritten = await context.metrics.counter(name: "records-written")
        let (_, emitter) = await client.makeStream(instruction: context.instruction, transform: context.transform)
        var bytes = 0
        var records = 0
        for try await element in inputs[0] {
            log.info("\(context.instruction)-\(context.transform) write \(String(describing: element))")
            var output = Data()
            try coder.encode(element, data: &output)

            bytes += output.count
            records += 1
            emitter.yield(.data(output))
        }
        bytesWritten(bytes)
        recordsWritten(records)
        emitter.yield(.last(context.instruction, context.transform))
        emitter.finish()
        await client.finalizeStream(instruction: context.instruction, transform: context.transform)
        return (context.instruction, context.transform)
    }
}
