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

public extension PCollection {
    /// Create a PCollection whose stream has been preloaded with some values for testing
    static func testValues<V: Beamable>(_ values: [V]) -> PCollection<V> {
        let stream = PCollectionStream<V>({ _,_ in })
        for v in values {
            stream.emit(v, timestamp: .now, window: .global)
        }
        return PCollection<V>(stream: stream)
    }

    /// Convenience function that simulates an impulse
    static func testImpulse() -> PCollection<Data> {
        testValues([Data()])
    }
}
