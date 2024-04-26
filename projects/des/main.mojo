from utils.variant import Variant
from collections import Optional
import random
import sys

struct Queue[T: CollectionElement](Sized):
    var arena: List[T]
    var head: Int

    fn __init__(inout self):
        self.arena = List[T]()
        self.head = 0

    fn push(inout self, value: T):
        self.arena.append(value)

    fn pop(inout self) raises -> T:
        if self.head >= len(self.arena):
            raise Error("Queue is empty")
        var value = self.arena[self.head]
        self.head = self.head + 1
        return value

    fn __len__(self) -> Int:
        return len(self.arena) - self.head

struct TimeEventHeap(Sized):
    var arena: List[TimeEvent]
    var taken: Int

    fn __init__(inout self):
        self.arena = List[TimeEvent]()
        self.taken = 0

    fn add(inout self, owned value: TimeEvent):
        self.arena.append(value^)

    fn pop(inout self) raises -> TimeEvent:
        if self.__len__() == 0:
            raise Error("Heap is empty")

        var min_time = Int.MAX
        var min_index: Int = -1

        for i in range(len(self.arena)):
            var time_event = self.arena[i]
            if not time_event.processed and time_event.time < min_time:
                min_time = time_event.time
                min_index = i
        
        self.taken = self.taken + 1
        self.arena[min_index].processed = True
        return self.arena[min_index]
        
    fn __len__(self) -> Int:
        return len(self.arena) - self.taken

@value
struct TimeEvent(CollectionElement):
    var time: Int
    var target_id: Int
    var processed: Bool

    fn __init__(inout self, time: Int, target_id: Int):
        self.time = time
        self.target_id = target_id
        self.processed = False

trait IProcess(CollectionElement):
    alias Dummy = DummyProcess

    fn __process__(inout self, id: Int):
        ...

    fn id(self) -> Int:
        ...

    fn run(self, time: Int) -> Int:
        ...

@value
struct DummyProcess(IProcess):
    var _id: Int

    fn __init__(inout self):
        self._id = -1

    fn __process__(inout self, id: Int):
        self._id = id

    fn id(self) -> Int:
        return self._id

    fn run(self, time: Int) -> Int:
        return -1

struct Environment[*Ts: CollectionElement]:
    alias RAND_SEED = -1
    alias TProcess = Variant[Ts]
    var init_time: Int
    var events: TimeEventHeap
    var time: Int
    var objects: List[Self.TProcess]
    var _run_process_fn: fn(Variant[Ts], Int)raises->Int
    var _seed: Int

    fn __init__(inout self, run_process_fn: fn(Self.TProcess, Int)raises->Int, init_time: Int = 0, seed: Int = Self.RAND_SEED):
        self.init_time = init_time
        self.time = init_time
        self.events = TimeEventHeap()
        self.objects = List[Self.TProcess]()
        self._run_process_fn = run_process_fn
        self._seed = seed

    fn process(inout self, owned spawner: Self.TProcess, time_offset: Int = 0):
        var t_process = spawner.get[IProcess.Dummy]()
        t_process[].__process__(len(self.objects))
        self.waitAndCall(time_offset, t_process[].id())

        self.objects.append(spawner^)

    fn waitAndCall(inout self, duration: Int, target_id: Int):
        self.events.add(TimeEvent(self.time + duration, target_id))

    fn run(inout self, until_time: Int) raises:
        self.time = self.init_time

        if self._seed > Self.RAND_SEED:
            random.seed(self._seed)
        else:
            random.seed()

        while len(self.events) > 0:
            var event = self.events.pop()
            self.time = event.time
            if self.time > until_time:
                break
            for obj in self.objects:
                var process = obj[].get[IProcess.Dummy]()[]
                if event.target_id == process.id():
                    var dur = self._run_process_fn(obj[], self.time)
                    if dur >= 0:
                        self.waitAndCall(dur, process.id())

import random

@value
struct VesselSpawner(IProcess):
    var _id: Int

    fn __init__(inout self):
        self._id = -1

    fn __process__(inout self, id: Int):
        self._id = id

    fn id(self) -> Int:
        return self._id

    fn run(self, time: Int) -> Int:
        print("Spawning vessel at time "+str(time))
        return -1

@value
struct TruckSpawner(IProcess):
    var _id: Int

    fn __init__(inout self):
        self._id = -1

    fn __process__(inout self, id: Int):
        self._id = id

    fn id(self) -> Int:
        return self._id

    fn run(self, time: Int) -> Int:
        print("Spawning truck at time "+str(time))
        return random.random_ui64(3, 7).to_int()

@value
struct Vessel(IProcess):
    var _id: Int

    fn __init__(inout self):
        self._id = -1

    fn __process__(inout self, id: Int):
        self._id = id

    fn id(self) -> Int:
        return self._id

    fn run(self, time: Int) -> Int:
        print("Vessel "+str(self.id())+" is running at time "+str(time))
        return -1

trait IObject(CollectionElement):
    fn run(self, world: AnyPointer[IWorld]) -> None:
        ...

@value
struct DummyObject(IObject):
    fn run(self, world: AnyPointer[IWorld]) -> None:
        print("Running object")

trait IWorld:
    fn spawn(inout self, obj: AnyPointer[IObject]) -> None:
        ...

struct World[T: IObject](IWorld):
    var _obj: T
    def __init__(inout self):
        self._obj = DummyObject()

    fn spawn(inout self, obj: AnyPointer[IObject]) -> None:
        # self._obj = obj
        pass

    fn run(inout self) -> None:
        pass

@value
struct MyObject(IObject):
    fn run(self, world: AnyPointer[IWorld]) -> None:
        print("Running object")

alias SimEnv = Environment[IProcess.Dummy, VesselSpawner, TruckSpawner, Vessel]
fn main() raises:

    var w = World[MyObject]()
    var o = MyObject()
    var data = AnyPointer[MyObject].alloc(1)
    data.emplace_value(o^)

    w.spawn(&o)

    fn run_process(process: SimEnv.TProcess, time: Int) raises -> Int:
        if process.isa[VesselSpawner]():
            return process.get[VesselSpawner]()[].run(time)
        elif process.isa[TruckSpawner]():
            return process.get[TruckSpawner]()[].run(time)
        elif process.isa[Vessel]():
            return process.get[Vessel]()[].run(time)
        else:
            raise Error("Unknown process")

    var env = SimEnv(run_process)
    env.process(env.TProcess(TruckSpawner()), 0)
    env.process(env.TProcess(VesselSpawner()), 6)
    env.run(20)