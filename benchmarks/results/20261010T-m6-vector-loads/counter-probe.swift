import Metal

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("No Metal device")
}

print("device=\(device.name)")
print("supportsCounterSamplingAtStageBoundary=\(device.supportsCounterSampling(.atStageBoundary))")
print("supportsCounterSamplingAtDrawBoundary=\(device.supportsCounterSampling(.atDrawBoundary))")
print("supportsCounterSamplingAtBlitBoundary=\(device.supportsCounterSampling(.atBlitBoundary))")

for counterSet in device.counterSets ?? [] {
    print("counterSet=\(counterSet.name)")
    for counter in counterSet.counters {
        print("  counter=\(counter.name)")
    }
}
